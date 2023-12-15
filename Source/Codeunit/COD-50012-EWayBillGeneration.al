codeunit 50012 "E-Way Bill Generartion"
{
    trigger OnRun()
    begin
    end;

    var
        G_Client_ID: Text;
        G_Client_Secret: Text;
        G_IP_Address: Text;
        G_Authenticate_URL: Text;
        G_Round_GL_Account_1: Code[20];
        G_Round_GL_Account_2: Code[20];
        G_E_Invoice_URL: Text;
        Team001: Label 'Error When Contacting API';

    procedure GenerateEWayBillFromIRN(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment")
    var
        JEWayPayload: JsonObject;
        EInvoiceSetup: Record "E-Invoice Set Up";
        GSTIN: Code[20];
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        LocationG: Record Location;
        PayloadText: Text;
    begin
        EInvoiceSetup.Get();
        G_Client_ID := EInvoiceSetup."Client ID";
        G_Client_Secret := EInvoiceSetup."Client Secret";
        G_IP_Address := EInvoiceSetup."IP Address";
        G_Round_GL_Account_1 := EInvoiceSetup."Round GL Account 1";
        G_Round_GL_Account_2 := EInvoiceSetup."Round GL Account 2";
        G_Authenticate_URL := EInvoiceSetup."Authentication URL";
        G_E_Invoice_URL := EInvoiceSetup."E-Invoice URl";
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if SalesInvoiceHeader.get(DocNo) then begin
                        GSTIN := SalesInvoiceHeader."Location GST Reg. No.";
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if SalesCrMemoHeader.get(DocNo) then
                        GSTIN := SalesCrMemoHeader."Location GST Reg. No.";
                end;
            DocumentType::"Transfer Shipment":
                begin
                    if TransferShipmentHeader.get(DocNo) then begin
                        if LocationG.get(TransferShipmentHeader."Transfer-from Code") then
                            GSTIN := LocationG."GST Registration No.";
                    end;
                end;
        end;

        ReadActionDetails(JEWayPayload, DocNo, DocumentType);
        ReadTransDetails(DocNo, DocumentType, JEWayPayload);
        ReadExpShipDtls(JEWayPayload, DocNo, DocumentType);
        WriteDispatchDetails(JEWayPayload);
        JEWayPayload.WriteTo(PayloadText);
        Message(PayloadText);
        AuthenticateToken(GSTIN);
        GenerateEwayRequestSendtobinary(DocNo, DocumentType, PayloadText, GSTIN);
    end;

    local procedure ReadActionDetails(var JReadActionDtls: JsonObject; DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment")
    var
        EWay_SalesInvoiceHeader: Record "Sales Invoice Header";
        EWay_SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EWay_transferShipmentHeader: Record "Transfer Shipment Header";
        Irnno: Text;
        Distance: Decimal;
    begin
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if EWay_SalesInvoiceHeader.get(DocNo) then begin
                        Irnno := EWay_SalesInvoiceHeader."IRN Hash";
                        if EWay_SalesInvoiceHeader."Distance (Km)" <> 0 then
                            Distance := EWay_SalesInvoiceHeader."Distance (Km)"
                        else
                            Distance := 0;
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if EWay_SalesCrMemoHeader.get(DocNo) then begin
                        Irnno := EWay_SalesCrMemoHeader."IRN Hash";
                        if EWay_SalesCrMemoHeader."Distance (Km)" <> 0 then
                            Distance := EWay_SalesCrMemoHeader."Distance (Km)"
                        else
                            Distance := 0;
                    end;
                end;
            DocumentType::"Transfer Shipment":
                begin
                    if EWay_transferShipmentHeader.get(DocNo) then begin
                        Irnno := EWay_transferShipmentHeader."APIS_IRN Hash";
                        if EWay_transferShipmentHeader."Distance (Km)" <> 0 then
                            Distance := EWay_transferShipmentHeader."Distance (Km)"
                        else
                            Distance := 0;
                    end;
                end;
        end;
        WriteActionDetails(JReadActionDtls, Irnno, Distance);
    end;

    local procedure WriteActionDetails(var JActionDtls: JsonObject; Irn: Text; Distance: Decimal)
    var

    begin
        JActionDtls.Add('ACTION', 'EWAYBILL');
        JActionDtls.Add('IRN', Irn);
        JActionDtls.Add('Distance', ReturnStr(RoundAmt(Distance)))
    end;

    local procedure ReadTransDetails(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment";
        var JReadTransDtls: JsonObject)
    var
        Trans_SalesInvoiceHeader: Record "Sales Invoice Header";
        Trans_SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Trans_TransferShipmentHeader: Record "Transfer Shipment Header";
        Trans_ShippingAgent: Record "Shipping Agent";
        TrnsMode: Text;
        TransID: Code[20];
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Code[20];
        TransVehNo: Text;
        TransVehType: Text;
    begin
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if Trans_SalesInvoiceHeader.get(DocNo) then begin
                        if Trans_SalesInvoiceHeader."Transport Method" <> '' then
                            TrnsMode := TransportMethod(Trans_SalesInvoiceHeader."Transport Method")
                        else
                            TrnsMode := '';
                        if Trans_SalesInvoiceHeader."Vehicle No." = '' then begin
                            IF NOT (Trans_SalesInvoiceHeader."Transport Method" = '') then
                                TrnsMode := '';
                        end;
                        if Trans_ShippingAgent.Get(Trans_SalesInvoiceHeader."Shipping Agent Code") then begin
                            TransID := Trans_ShippingAgent."GST Registration No.";
                            TransName := Trans_ShippingAgent.Name;
                        end else begin
                            TransID := '';
                            TransName := '';
                        end;
                        if not (Trans_SalesInvoiceHeader."LR/RR Date" = 0D) then
                            TransDocDt := FORMAT(Trans_SalesInvoiceHeader."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>')
                        else
                            TransDocDt := '';
                        if not (Trans_SalesInvoiceHeader."LR/RR No." = '') then
                            TransDocNo := Trans_SalesInvoiceHeader."LR/RR No."
                        else
                            TransDocNo := '';
                        if not (Trans_SalesInvoiceHeader."Vehicle No." = '') then
                            TransVehNo := Trans_SalesInvoiceHeader."Vehicle No."
                        else
                            TransVehNo := '';
                        if (Trans_SalesInvoiceHeader."Vehicle Type" = Trans_SalesInvoiceHeader."Vehicle Type"::" ") then
                            TransVehType := ''
                        else
                            if (Trans_SalesInvoiceHeader."Vehicle Type" = Trans_SalesInvoiceHeader."Vehicle Type"::ODC) then
                                TransVehType := 'O'
                            else
                                if (Trans_SalesInvoiceHeader."Vehicle Type" = Trans_SalesInvoiceHeader."Vehicle Type"::Regular) then
                                    TransVehType := 'R';
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if Trans_SalesCrMemoHeader.get(DocNo) then begin
                        if Trans_SalesCrMemoHeader."Transport Method" <> '' then
                            TrnsMode := TransportMethod(Trans_SalesCrMemoHeader."Transport Method")
                        else
                            TrnsMode := '';
                        if Trans_SalesCrMemoHeader."Vehicle No." = '' then begin
                            if not (Trans_SalesCrMemoHeader."Transport Method" = '') then
                                TrnsMode := '';
                        end;
                        if Trans_ShippingAgent.Get(Trans_SalesCrMemoHeader."Shipping Agent Code") then begin
                            TransID := Trans_ShippingAgent."GST Registration No.";
                            TransName := Trans_ShippingAgent.Name;
                        end else begin
                            TransID := '';
                            TransName := '';
                        end;
                        if not (Trans_SalesCrMemoHeader."APIS_LR/RR Date" = 0D) then
                            TransDocDt := FORMAT(Trans_SalesCrMemoHeader."APIS_LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>')
                        else
                            TransDocDt := '';
                        if not (Trans_SalesCrMemoHeader."APIS_LR/RR No." = '') then
                            TransDocNo := Trans_SalesCrMemoHeader."APIS_LR/RR No."
                        else
                            TransDocNo := '';
                        if not (Trans_SalesCrMemoHeader."Vehicle No." = '') then
                            TransVehNo := Trans_SalesCrMemoHeader."Vehicle No."
                        else
                            TransVehNo := '';
                        if (Trans_SalesCrMemoHeader."Vehicle Type" = Trans_SalesCrMemoHeader."Vehicle Type"::" ") then
                            TransVehType := ''
                        else
                            if (Trans_SalesCrMemoHeader."Vehicle Type" = Trans_SalesCrMemoHeader."Vehicle Type"::ODC) then
                                TransVehType := 'O'
                            else
                                if (Trans_SalesCrMemoHeader."Vehicle Type" = Trans_SalesCrMemoHeader."Vehicle Type"::Regular) then
                                    TransVehType := 'R';
                    end;
                end;
            DocumentType::"Transfer Shipment":
                begin
                    if Trans_TransferShipmentHeader.get(DocNo) then begin
                        if Trans_TransferShipmentHeader."Transport Method" <> '' then
                            TrnsMode := TransportMethod(Trans_TransferShipmentHeader."Transport Method")
                        else
                            TrnsMode := '';
                        if Trans_TransferShipmentHeader."Vehicle No." = '' then begin
                            if not (Trans_TransferShipmentHeader."Transport Method" = '') then
                                TrnsMode := '';
                        end;
                        if Trans_ShippingAgent.Get(Trans_TransferShipmentHeader."Shipping Agent Code") then begin
                            TransID := Trans_ShippingAgent."GST Registration No.";
                            TransName := Trans_ShippingAgent.Name;
                        end else begin
                            TransID := '';
                            TransName := '';
                        end;
                        if not (Trans_TransferShipmentHeader."LR/RR Date" = 0D) then
                            TransDocDt := FORMAT(Trans_TransferShipmentHeader."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>')
                        else
                            TransDocDt := '';
                        if not (Trans_TransferShipmentHeader."LR/RR No." = '') then
                            TransDocNo := Trans_TransferShipmentHeader."LR/RR No."
                        else
                            TransDocNo := '';
                        if not (Trans_TransferShipmentHeader."Vehicle No." = '') then
                            TransVehNo := Trans_TransferShipmentHeader."Vehicle No."
                        else
                            TransVehNo := '';
                        if (Trans_TransferShipmentHeader."Vehicle Type" = Trans_TransferShipmentHeader."Vehicle Type"::" ") then
                            TransVehType := ''
                        else
                            if (Trans_TransferShipmentHeader."Vehicle Type" = Trans_TransferShipmentHeader."Vehicle Type"::ODC) then
                                TransVehType := 'O'
                            else
                                if (Trans_TransferShipmentHeader."Vehicle Type" = Trans_TransferShipmentHeader."Vehicle Type"::Regular) then
                                    TransVehType := 'R';
                    end;
                end;
        end;
        WriteTrnsDeatils(JReadTransDtls, TrnsMode, TransID, TransName, TransDocDt, TransDocNo, TransVehNo, TransVehType);
    end;

    local procedure WriteTrnsDeatils(var JWriteTransDetais: JsonObject; TransMode: Text; TransID: Code[20];
      TransName: Text; TransDocDt: Text; TransDocNo: Code[20]; TransVehNo: Text; TransVehType: Text)
    var
        JsonNull: JsonValue;
    begin
        JsonNull.SetValueToNull();
        if TransMode <> '' then
            JWriteTransDetais.Add('TransMode', TransMode)
        else
            JWriteTransDetais.Add('TransMode', JsonNull);
        if TransID <> '' then
            JWriteTransDetais.Add('TransId', TransID)
        else
            JWriteTransDetais.Add('TransId', JsonNull);
        if TransName <> '' then
            JWriteTransDetais.Add('TransName', TransName)
        else
            JWriteTransDetais.Add('TransName', JsonNull);
        if TransDocDt <> '' then
            JWriteTransDetais.Add('TransDocDt', TransDocDt)
        else
            JWriteTransDetais.Add('TransDocDt', JsonNull);
        if TransDocNo <> '' then
            JWriteTransDetais.Add('TransDocNo', TransDocNo)
        else
            JWriteTransDetais.Add('TransDocNo', JsonNull);
        if TransVehNo <> '' then
            JWriteTransDetais.Add('VehNo', TransVehNo)
        else
            JWriteTransDetais.Add('VehNo', JsonNull);
        if TransVehType <> '' then
            JWriteTransDetais.Add('VehType', TransVehType)
        else
            JWriteTransDetais.Add('VehType', JsonNull);
    end;

    local procedure ReadExpShipDtls(var JReadExpShip: JsonObject; DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment")
    var
        Ship_SalesInvoiceHeader: Record "Sales Invoice Header";
        Ship_SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Ship_State: Record State;
        Addrs1: Text;
        Addrs2: Text;
        Location: Text;
        PinCode: Text;
        StateCode: Code[2];
        IsExpShipDtls: Boolean;
    begin
        IsExpShipDtls := false;
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if Ship_SalesInvoiceHeader.get(DocNo) then begin
                        if Ship_SalesInvoiceHeader."Ship-to Code" <> '' then begin
                            Addrs1 := Ship_SalesInvoiceHeader."Ship-to Address";
                            Addrs2 := Ship_SalesInvoiceHeader."Ship-to Address 2";
                            Location := Ship_SalesInvoiceHeader."Ship-to City";
                            PinCode := Ship_SalesInvoiceHeader."Ship-to Post Code";
                            if Ship_State.get(Ship_SalesInvoiceHeader."GST Ship-to State Code") then
                                StateCode := Ship_State."APIS_State Code forE-Invoicing";
                            IsExpShipDtls := true;
                        end;
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if Ship_SalesCrMemoHeader.get(DocNo) then begin
                        if Ship_SalesCrMemoHeader."Ship-to Code" <> '' then begin
                            Addrs1 := Ship_SalesCrMemoHeader."Ship-to Address";
                            Addrs2 := Ship_SalesCrMemoHeader."Ship-to Address 2";
                            Location := Ship_SalesCrMemoHeader."Ship-to City";
                            PinCode := Ship_SalesCrMemoHeader."Ship-to Post Code";
                            if Ship_State.get(Ship_SalesCrMemoHeader."GST Ship-to State Code") then
                                StateCode := Ship_State."APIS_State Code forE-Invoicing";
                            IsExpShipDtls := true;
                        end;
                    end;
                end;
        end;
        WriteExpShipDtls(JReadExpShip, Addrs1, Addrs2, Location, PinCode, StateCode, IsExpShipDtls);
    end;

    local procedure WriteExpShipDtls(var JWriteShipDtls: JsonObject; Addrs1: Text; Addrs2: Text; Location: Text; PinCode: Text;
        StateCode: Code[2]; IsExpShipDtls: Boolean)
    var
        JWriteShDtls: JsonObject;
        JsonNull: JsonValue;
    begin
        JsonNull.SetValueToNull();
        if IsExpShipDtls then begin
            JWriteShDtls.Add('Addr1', Addrs1);
            JWriteShDtls.Add('Addr2', Addrs2);
            JWriteShDtls.Add('Loc', Location);
            JWriteShDtls.Add('Pin', PinCode);
            JWriteShDtls.Add('Stcd', StateCode);
            JWriteShipDtls.Add('ExpShipDtls', JWriteShDtls);
        end else
            JWriteShipDtls.Add('ExpShipDtls', JsonNull);
    end;

    local procedure WriteDispatchDetails(Var JwriteDispDtls: JsonObject)
    var
        NullValue: JsonValue;
    begin
        NullValue.SetValueToNull();
        JwriteDispDtls.Add('DispDtls', NullValue);
    end;

    local procedure ReturnStr(Amt: Decimal): Text
    begin
        EXIT(DELCHR(FORMAT(Amt), '=', ','));
    end;

    local procedure RoundAmt(Amt: Decimal): Decimal
    var
    begin
        exit(Round(Amt, 0.01, '='))
    end;

    local procedure TransportMethod(DocNo: Code[20]): text
    var
        TransMethod: Record "Transport Method";
    begin
        if TransMethod.get(DocNo) then begin
            if TransMethod."Transportation Mode" = TransMethod."Transportation Mode"::Road then
                exit('1')
            else
                if TransMethod."Transportation Mode" = TransMethod."Transportation Mode"::Rail then
                    exit('2')
                else
                    if TransMethod."Transportation Mode" = TransMethod."Transportation Mode"::Air then
                        exit('3')
                    else
                        if TransMethod."Transportation Mode" = TransMethod."Transportation Mode"::Ship then
                            exit('4');
        end;
    end;

    local procedure AuthenticateToken(GSTIN: Code[16])
    var
        EinvoiceHttpClient: HttpClient;
        EinvoiceHttpRequest: HttpRequestMessage;
        EinvoiceHttpContent: HttpContent;
        EinvoiceHttpHeader: HttpHeaders;
        EinvoiceHttpResponse: HttpResponseMessage;
        JOutputObject: JsonObject;
        JResultToken: JsonToken;
        JResultObject: JsonObject;
        OutputMessage: Text;
        ResultMessage: Text;
    begin
        EinvoiceHttpContent.WriteFrom(SetEinvoiceUserIDandPassword(GSTIN));
        EinvoiceHttpContent.GetHeaders(EinvoiceHttpHeader);
        EinvoiceHttpHeader.Clear();
        EinvoiceHttpHeader.Add('client_id', G_Client_ID);
        EinvoiceHttpHeader.Add('client_secret', G_Client_Secret);
        EinvoiceHttpHeader.Add('IPAddress', G_IP_Address);
        EinvoiceHttpHeader.Add('Content-Type', 'application/json');
        EinvoiceHttpRequest.Content := EinvoiceHttpContent;
        EinvoiceHttpRequest.SetRequestUri(G_Authenticate_URL);
        EinvoiceHttpRequest.Method := 'POST';
        if EinvoiceHttpClient.Send(EinvoiceHttpRequest, EinvoiceHttpResponse) then begin
            EinvoiceHttpResponse.Content.ReadAs(ResultMessage);
            JResultObject.ReadFrom(ResultMessage);
            if JResultObject.Get('MessageId', JResultToken) then
                if JResultToken.AsValue().AsInteger() = 1 then begin
                    if JResultObject.Get('Message', JResultToken) then;
                    //Message(Format(JResultToken));
                end else
                    if JResultObject.Get('Message', JResultToken) then
                        Message(Format(JResultToken));
            if JResultToken.IsObject then begin
                JResultToken.WriteTo(OutputMessage);
                JOutputObject.ReadFrom(OutputMessage);
            end;
        end else
            Message(Team001);
    end;

    local procedure SetEinvoiceUserIDandPassword(GSTIN: Code[16]) JsonTxt: Text
    var
        JsonObj: JsonObject;
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        if GSTRegistrationNos.Get(GSTIN) then;
        JsonObj.Add('action', 'ACCESSTOKEN');
        JsonObj.Add('UserName', GSTRegistrationNos."APIS_User Name");
        JsonObj.Add('Password', GSTRegistrationNos."APIS_Password");
        JsonObj.Add('Gstin', GSTRegistrationNos.Code);
        JsonObj.WriteTo(JsonTxt);
        // Message(JsonTxt);
    end;

    local procedure GenerateEwayRequestSendtobinary(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment"; JsonPayload: Text; GSTIN: Code[20])
    var
        EInvoiceLog: Record E_Invoice_Log;
        Outstrm: OutStream;
        RequestResponse: BigText;
        EwayBillN: Text[50];
        GSTRegistrationNos: Record "GST Registration Nos.";
        EinvoiceHttpContent: HttpContent;
        EinvoiceHttpHeader: HttpHeaders;
        EinvoiceHttpRequest: HttpRequestMessage;
        EinvoiceHttpClient: HttpClient;
        EinvoiceHttpResponse: HttpResponseMessage;
        JOutputObject: JsonObject;
        JOutputToken: JsonToken;
        JResultToken: JsonToken;
        JResultObject: JsonObject;
        OutputMessage: Text;
        ResultMessage: Text;
        EWayBillDate: DateTime;
        YearCode: Integer;
        MonthCode: Integer;
        DayCode: Integer;
        EwaybillDateText: Text;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        ErrorMsg: Text;
        EWayGenerated: Boolean;
    begin
        EWayGenerated := false;
        EwayBillN := '';
        EwaybillDateText := '';
        EWayBillDate := 0DT;
        ErrorMsg := '';
        if GSTRegistrationNos.get(GSTIN) then;
        EinvoiceHttpContent.WriteFrom(Format(JsonPayload));
        EinvoiceHttpContent.GetHeaders(EinvoiceHttpHeader);
        EinvoiceHttpHeader.Clear();
        EinvoiceHttpHeader.Add('client_id', G_Client_ID);
        EinvoiceHttpHeader.Add('client_secret', G_Client_Secret);
        EinvoiceHttpHeader.Add('IPAddress', G_IP_Address);
        EinvoiceHttpHeader.Add('Content-Type', 'application/json');
        EinvoiceHttpHeader.Add('user_name', GSTRegistrationNos."APIS_User Name");
        EinvoiceHttpHeader.Add('Gstin', GSTRegistrationNos.Code);
        EinvoiceHttpRequest.Content := EinvoiceHttpContent;
        EinvoiceHttpRequest.SetRequestUri(G_E_Invoice_URL);
        EinvoiceHttpRequest.Method := 'POST';
        if EinvoiceHttpClient.Send(EinvoiceHttpRequest, EinvoiceHttpResponse) then begin
            EinvoiceHttpResponse.Content.ReadAs(ResultMessage);
            JResultObject.ReadFrom(ResultMessage);

            if JResultObject.Get('MessageId', JResultToken) then
                if JResultToken.AsValue().AsInteger() = 1 then begin
                    if JResultObject.Get('Message', JResultToken) then;
                    //Message(Format(JResultToken));
                end else begin
                    if JResultObject.Get('Message', JResultToken) then
                        ErrorMsg := JResultToken.AsValue().AsText();
                    Message('%1,%2', ErrorMsg, 'E-Way Bill Generation Failed');
                end;

            if JResultObject.Get('Data', JResultToken) then
                if JResultToken.IsObject then begin
                    JResultToken.WriteTo(OutputMessage);
                    JOutputObject.ReadFrom(OutputMessage);
                    if JOutputObject.Get('EwbDt', JOutputToken) then
                        EwaybillDateText := JOutputToken.AsValue().AsText();
                    Evaluate(YearCode, CopyStr(EwaybillDateText, 1, 4));
                    Evaluate(MonthCode, CopyStr(EwaybillDateText, 6, 2));
                    Evaluate(DayCode, CopyStr(EwaybillDateText, 9, 2));
                    Evaluate(EWayBillDate, Format(DMY2Date(DayCode, MonthCode, YearCode)) + ' ' + Copystr(EwaybillDateText, 12, 8));
                    if JOutputObject.Get('EwbNo', JOutputToken) then
                        EwayBillN := JOutputToken.AsValue().AsText();
                    EWayGenerated := true;
                    Message('E-Way Bill Generated Successfully!!');
                end;
            case
                DocumentType of
                DocumentType::Invoice:
                    begin
                        if SalesInvoiceHeader.get(DocNo) then begin
                            SalesInvoiceHeader."E-Way Bill No." := EwayBillN;
                            SalesInvoiceHeader."APIS_E-Way Bill Date Time" := EWayBillDate;
                            SalesInvoiceHeader."APIS_E-Way Bill CancelDateTime" := 0DT;
                            SalesInvoiceHeader.Modify();
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::Invoice);
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := EwayBillN;
                            EInvoiceLog."E-Way Bill Date Time" := EWayBillDate;
                            if EWayGenerated then
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Submitted
                            else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Failed;
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."E-Way Bill Cancel DateTime" := 0DT;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(JsonPayload);
                            EInvoiceLog."G_E-Way bill Sent Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."G_E-Way bill Output Response".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
                DocumentType::"Credit Memo":
                    begin
                        if SalesCrMemoHeader.get(DocNo) then begin
                            SalesCrMemoHeader."E-Way Bill No." := EwayBillN;
                            SalesCrMemoHeader."APIS_E-Way Bill Date Time" := EWayBillDate;
                            SalesCrMemoHeader."APIS_E-Way Bill CancelDateTime" := 0DT;
                            SalesCrMemoHeader.Modify();
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := EwayBillN;
                            EInvoiceLog."E-Way Bill Date Time" := EWayBillDate;
                            if EWayGenerated then
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Submitted
                            else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Failed;
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."E-Way Bill Cancel DateTime" := 0DT;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(JsonPayload);
                            EInvoiceLog."G_E-Way bill Sent Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."G_E-Way bill Output Response".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
                DocumentType::"Transfer Shipment":
                    begin
                        if TransferShipmentHeader.get(DocNo) then begin
                            TransferShipmentHeader."APIS_E-Way Bill No." := EwayBillN;
                            TransferShipmentHeader."APIS_E-Way Bill Date Time" := EWayBillDate;
                            TransferShipmentHeader."APIS_E-Way Bill CancelDateTime" := 0DT;
                            TransferShipmentHeader.Modify();
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::Invoice);
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := EwayBillN;
                            EInvoiceLog."E-Way Bill Date Time" := EWayBillDate;
                            if EWayGenerated then
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Submitted
                            else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Failed;
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            EInvoiceLog."E-Way Bill Cancel DateTime" := 0DT;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(JsonPayload);
                            EInvoiceLog."G_E-Way bill Sent Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."G_E-Way bill Output Response".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
            end;
        end else
            Message(Team001);
    end;

    procedure CancelEWayBill(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment")
    var
        Body: Text;
        EinvoiceHttpContent: HttpContent;
        EinvoiceHttpHeader: HttpHeaders;
        EinvoiceHttpRequest: HttpRequestMessage;
        EinvoiceHttpClient: HttpClient;
        EinvoiceHttpResponse: HttpResponseMessage;
        JResultToken: JsonToken;
        JResultObject: JsonObject;
        ResultMessage: Text;
        EinvoiceSetup: Record "E-Invoice Set Up";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        LocationG: Record Location;
        GSTIN: Code[20];
        EWayCancel: Boolean;
        JOutputObject: JsonObject;
        JOutputToken: JsonToken;
        EwayBillN: Code[50];
        OutputMessage: Text;
        RequestResponse: BigText;
        Outstrm: OutStream;
        EInvoiceLog: Record E_Invoice_Log;
        EWayBillDate: DateTime;
        YearCode: Integer;
        MonthCode: Integer;
        DayCode: Integer;
        EwaybillDateText: Text;

        ErrorMsg: Text;

    begin
        EinvoiceSetup.Get();
        G_Client_ID := EInvoiceSetup."Client ID";
        G_Client_Secret := EInvoiceSetup."Client Secret";
        G_IP_Address := EInvoiceSetup."IP Address";
        G_Authenticate_URL := EInvoiceSetup."Authentication URL";
        G_E_Invoice_URL := EInvoiceSetup."E-Invoice URl";
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if SalesInvoiceHeader.get(DocNo) then begin
                        GSTIN := SalesInvoiceHeader."Location GST Reg. No.";
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if SalesCrMemoHeader.get(DocNo) then
                        GSTIN := SalesCrMemoHeader."Location GST Reg. No.";
                end;
            DocumentType::"Transfer Shipment":
                begin
                    if TransferShipmentHeader.get(DocNo) then begin
                        if LocationG.get(TransferShipmentHeader."Transfer-from Code") then
                            GSTIN := LocationG."GST Registration No.";
                    end;
                end;
        end;
        AuthenticateToken(GSTIN);
        ReadCancelEWayBillBody(DocNo, DocumentType, Body);
        EinvoiceHttpContent.WriteFrom(Format(Body));
        EinvoiceHttpContent.GetHeaders(EinvoiceHttpHeader);
        EinvoiceHttpHeader.Clear();
        // For Productuion
        EinvoiceHttpHeader.Add('PRIVATEKEY', EinvoiceSetup."Private Key");
        EinvoiceHttpHeader.Add('PRIVATEVALUE', EinvoiceSetup."Private Value");
        EinvoiceHttpHeader.Add('IP', EinvoiceSetup."Private IP");
        EinvoiceHttpHeader.Add('Content-Type', 'application/json');
        EinvoiceHttpHeader.Add('Gstin', GSTIN);
        EinvoiceHttpRequest.Content := EinvoiceHttpContent;
        EinvoiceHttpRequest.SetRequestUri(EinvoiceSetup."Cancel E-Way Bill URL");
        EinvoiceHttpRequest.Method := 'POST';
        // For Productuion
        if EinvoiceHttpClient.Send(EinvoiceHttpRequest, EinvoiceHttpResponse) then begin
            EinvoiceHttpResponse.Content.ReadAs(ResultMessage);
            JResultObject.ReadFrom(ResultMessage);
            //Message(ResultMessage);
            if JResultObject.Get('MessageId', JResultToken) then
                if JResultToken.AsValue().AsInteger() = 1 then begin
                    if JResultObject.Get('Message', JResultToken) then;
                    //Message(Format(JResultToken));
                end else begin
                    if JResultObject.Get('Message', JResultToken) then
                        ErrorMsg := JResultToken.AsValue().AsText();
                    Message('%1,%2', ErrorMsg, 'E-Way Bill Cancel Failed');
                end;

            if JResultObject.Get('Data', JResultToken) then
                if JResultToken.IsObject then begin
                    JResultToken.WriteTo(OutputMessage);
                    JOutputObject.ReadFrom(OutputMessage);
                    if JOutputObject.Get('CancelDate', JOutputToken) then
                        EwaybillDateText := JOutputToken.AsValue().AsText();
                    Evaluate(YearCode, CopyStr(EwaybillDateText, 1, 4));
                    Evaluate(MonthCode, CopyStr(EwaybillDateText, 6, 2));
                    Evaluate(DayCode, CopyStr(EwaybillDateText, 9, 2));
                    Evaluate(EWayBillDate, Format(DMY2Date(DayCode, MonthCode, YearCode)) + ' ' + Copystr(EwaybillDateText, 12, 8));
                    if JOutputObject.Get('EwbNo', JOutputToken) then
                        EwayBillN := JOutputToken.AsValue().AsText();
                    EWayCancel := true;
                    Message('E-Way Bill Cancel Successfully!!');
                end;
            case
                DocumentType of
                DocumentType::Invoice:
                    begin
                        if SalesInvoiceHeader.get(DocNo) then begin
                            if EWayCancel then begin
                                SalesInvoiceHeader."E-Way Bill No." := '';
                                SalesInvoiceHeader."APIS_E-Way Bill CancelDateTime" := EWayBillDate;
                                SalesInvoiceHeader.Modify();
                            end;
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::Invoice);
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("E-Way Bill Status", EInvoiceLog."E-Way Bill Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := '';
                            if EWayCancel then begin
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Cancelled;
                                EInvoiceLog."E-Way Bill Cancel DateTime" := EWayBillDate;
                            end else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::"Cancel Failed";
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(Body);
                            EInvoiceLog."E-Way Bill Cancel Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."E-Way Bill Cancel Output".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
                DocumentType::"Credit Memo":
                    begin
                        if SalesCrMemoHeader.get(DocNo) then begin
                            if EWayCancel then begin
                                SalesCrMemoHeader."E-Way Bill No." := '';
                                SalesCrMemoHeader."APIS_E-Way Bill CancelDateTime" := EWayBillDate;
                                SalesCrMemoHeader.Modify();
                            end;
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("E-Way Bill Status", EInvoiceLog."E-Way Bill Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := '';
                            if EWayCancel then begin
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Cancelled;
                                EInvoiceLog."E-Way Bill Cancel DateTime" := EWayBillDate;
                            end else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::"Cancel Failed";
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(Body);
                            EInvoiceLog."E-Way Bill Cancel Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."E-Way Bill Cancel Output".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
                DocumentType::"Transfer Shipment":
                    begin
                        if TransferShipmentHeader.get(DocNo) then begin
                            if EWayCancel then begin
                                TransferShipmentHeader."APIS_E-Way Bill No." := '';
                                TransferShipmentHeader."APIS_E-Way Bill CancelDateTime" := EWayBillDate;
                                TransferShipmentHeader.Modify();
                            end;
                        end;
                        EInvoiceLog.Reset();
                        EInvoiceLog.SetRange(EInvoiceLog."Document Type", EInvoiceLog."Document Type"::Invoice);
                        EInvoiceLog.SetRange("IRN Status", EInvoiceLog."IRN Status"::Submitted);
                        EInvoiceLog.SetRange("E-Way Bill Status", EInvoiceLog."E-Way Bill Status"::Submitted);
                        EInvoiceLog.SetRange("No.", DocNo);
                        if EInvoiceLog.FindFirst() then begin
                            EInvoiceLog."E-Way Bill No" := '';
                            if EWayCancel then begin
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::Cancelled;
                                EInvoiceLog."E-Way Bill Cancel DateTime" := EWayBillDate;
                            end else
                                EInvoiceLog."E-Way Bill Status" := EInvoiceLog."E-Way Bill Status"::"Cancel Failed";
                            EInvoiceLog."Error Message" := ErrorMsg;
                            EInvoiceLog."Current Date Time" := CurrentDateTime;
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(Body);
                            EInvoiceLog."E-Way Bill Cancel Request".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            CLEAR(RequestResponse);
                            RequestResponse.ADDTEXT(ResultMessage);
                            EInvoiceLog."E-Way Bill Cancel Output".CREATEOUTSTREAM(Outstrm);
                            RequestResponse.WRITE(Outstrm);
                            EInvoiceLog.Modify();
                        end;
                    end;
            end;
        end else
            Message(Team001);
    end;

    local procedure ReadCancelEWayBillBody(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment"; Var CancelBody: Text)
    var
        EWB_SalesInoviceHeader: Record "Sales Invoice Header";
        EWB_SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EWB_TransferShipmentHeader: Record "Transfer Shipment Header";
        EWB_Location: Record Location;
        GSTIN: Code[20];
        EWBNo: Code[50];
        CancelReason: Text;
        CancelRemarks: Text;
    begin
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if EWB_SalesInoviceHeader.get(DocNo) then begin
                        GSTIN := format(EWB_SalesInoviceHeader."Location GST Reg. No.");
                        EWBNo := format(EWB_SalesInoviceHeader."E-Way Bill No.");
                        CancelReason := format(EWB_SalesInoviceHeader."Cancel Reason");
                        CancelRemarks := format(EWB_SalesInoviceHeader."APIS_Cancel Remarks");
                    end;
                end;
            DocumentType::"Credit Memo":
                begin
                    if EWB_SalesCrMemoHeader.get(DocNo) then begin
                        GSTIN := format(EWB_SalesCrMemoHeader."Location GST Reg. No.");
                        EWBNo := format(EWB_SalesCrMemoHeader."E-Way Bill No.");
                        CancelReason := format(EWB_SalesCrMemoHeader."Cancel Reason");
                        CancelRemarks := format(EWB_SalesCrMemoHeader."APIS_Cancel Remarks");
                    end;
                end;
            DocumentType::"Transfer Shipment":
                begin
                    if EWB_TransferShipmentHeader.get(DocNo) then begin
                        if EWB_Location.get(EWB_TransferShipmentHeader."Transfer-from Code") then
                            GSTIN := format(EWB_Location."GST Registration No.");
                        EWBNo := format(EWB_TransferShipmentHeader."APIS_E-Way Bill No.");
                        CancelReason := format(EWB_TransferShipmentHeader."APIS_Cancel Reason");
                        CancelRemarks := format(EWB_TransferShipmentHeader."APIS_Cancel Remarks");
                    end;
                end;
        end;
        WriteCancelEWayBiilBody(CancelBody, GSTIN, EWBNo, CancelReason, CancelRemarks);
    end;

    local procedure WriteCancelEWayBiilBody(var CancelBody: Text; GSTIN: Code[20];
        EWBNo: Code[50]; CancelReason: Text; CancelRemarks: Text)
    var
        CanclEwayObject: JsonObject;
        CanclEwayObject2: JsonObject;
        CanclEwayArray: JsonArray;
    begin
        CanclEwayObject.Add('action', 'action');
        CanclEwayObject2.Add('Generator_Gstin', GSTIN);
        CanclEwayObject2.Add('ewbNo', EWBNo);
        CanclEwayObject2.Add('CancelReason', CancelReason);
        CanclEwayObject2.Add('cancelRmrk', CancelRemarks);
        CanclEwayArray.Add(CanclEwayObject2);
        CanclEwayObject.Add('data', CanclEwayArray);
        CanclEwayObject.WriteTo(CancelBody);
    end;

    procedure DownloadEwayBillPDF(DocNo: Code[20]; DocumentType: Option " ",Invoice,"Credit Memo","Transfer Shipment")
    var
        URLtext: Text;
        Instr: InStream;
        EinvoiceHttpHeader: HttpHeaders;
        EinvoiceHttpRequest: HttpRequestMessage;
        EinvoiceHttpResponse: HttpResponseMessage;
        EinvoiceHttpClient: HttpClient;
        FileName: text;
        Location: Record Location;
        EInvoiceSetup: Record "E-Invoice Set Up";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        EWayBillNo: Code[50];
        GSTINNo: Code[20];
    begin
        Clear(EWayBillNo);
        Clear(GSTINNo);
        EInvoiceSetup.Get();
        EInvoiceSetUp.TestField("Private Key");
        EInvoiceSetUp.TestField("Private Value");
        EInvoiceSetUp.TestField("Private IP");
        EInvoiceSetUp.TestField("Download E-Way Bill URL");
        case
            DocumentType of
            DocumentType::Invoice:
                begin
                    if SalesInvoiceHeader.get(DocNo) then begin
                        EWayBillNo := SalesInvoiceHeader."E-Way Bill No.";
                        GSTINNo := SalesInvoiceHeader."Location GST Reg. No.";
                    end;
                end;

            DocumentType::"Transfer Shipment":
                begin
                    if TransferShipmentHeader.get(DocNo) then begin
                        EWayBillNo := TransferShipmentHeader."APIS_E-Way Bill No.";
                        if Location.Get(TransferShipmentHeader."Transfer-from Code") then
                            GSTINNo := Location."GST Registration No.";
                    end;
                end;
        end;

        URLtext := EInvoiceSetup."Download E-Way Bill URL" + '?GSTIN=' + GSTINNo + '&EWBNO=' + EWayBillNo + '&action=GETEWAYBILL';
        // URLtext := EInvoiceSetup."Download E-Way Bill URL" + '?GSTIN=' + '05AAACE1268K1ZR' + '&EWBNO=' + SalesInvoiceHeader."E-Way Bill No." + '&action=GETEWAYBILL';
        EinvoiceHttpRequest.SetRequestUri(URLtext);
        EinvoiceHttpHeader.Clear();
        EinvoiceHttpRequest.GetHeaders(EinvoiceHttpHeader);
        EinvoiceHttpRequest.Method := 'GET';
        EinvoiceHttpHeader.Add('accept', 'application/json');
        EinvoiceHttpHeader.TryAddWithoutValidation('PRIVATEKEY', EInvoiceSetup."Private Key");
        EinvoiceHttpHeader.TryAddWithoutValidation('PRIVATEVALUE', EInvoiceSetup."Private Value");
        EinvoiceHttpHeader.TryAddWithoutValidation('IP', EInvoiceSetup."Private IP");
        EinvoiceHttpHeader.TryAddWithoutValidation('Gstin', GSTINNo);
        if EinvoiceHttpClient.Send(EinvoiceHttpRequest, EinvoiceHttpResponse) then begin
            EinvoiceHttpResponse.Content.ReadAs(Instr);
            FileName := EWayBillNo + '.pdf';
            DownloadFromStream(Instr, 'Export', '', 'All Files (*.*)|*.*', FileName);
            //   Hyperlink('C:/Users/15800/Downloads/701303098188.pdf');
        end;
    END;
}