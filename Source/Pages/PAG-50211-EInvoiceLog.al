page 50211 "E-Invoice Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = E_Invoice_Log;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = all;
                }
                field("Acknowledge No."; Rec."Acknowledge No.")
                {
                    Editable = false;
                }
                field("Acknowledge Date"; Rec."Acknowledge Date")
                {
                    Editable = false;
                }
                field("IRN Hash"; Rec."IRN Hash")
                {
                    Editable = false;
                }
                field("QR Code"; Rec."QR Code")
                {
                    Editable = false;
                }
                field("Current Date Time"; Rec."Current Date Time")
                {
                    Editable = false;
                }
                field("IRN Generated"; Rec."IRN Status")
                {
                    Editable = false;
                }
                field("Irn Cancel Date Time"; Rec."Irn Cancel Date Time")
                {
                    ApplicationArea = all;
                }
                field("E-Way Bill No"; Rec."E-Way Bill No")
                {
                    ApplicationArea = all;
                }
                field("E-Way Bill Date Time"; Rec."E-Way Bill Date Time")
                {
                    ApplicationArea = all;
                }
                field("E-Way Bill Status"; Rec."E-Way Bill Status")
                {
                    ApplicationArea = all;
                }
                field("E-Way Bill Cancel DateTime"; Rec."E-Way Bill Cancel DateTime")
                {
                    ApplicationArea = all;
                }
                /* field("Sent Response"; SendResponse)
                {
                }
                field("Output Response"; OutputResPonse)
                {
                } */
            }
        }
        area(Factboxes) { }
    }

    actions
    {
        area(Processing)
        {
            action("Generate IRN Sent Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = GIRNSent;
                trigger OnAction()

                begin
                    Rec.CALCFIELDS("G_IRN Sent Request");
                    if not Rec."G_IRN Sent Request".HasValue then
                        exit;
                    MESSAGE(Rec.GenerateIRNSentResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."G_IRN Sent Request".CreateInStream(Instrm);
                    FileName := Rec."No." + '_IRN Request Payload' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Generate IRN Output Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = GIRNOutput;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("G_IRN Output Response");
                    if not Rec."G_IRN Output Response".HasValue then
                        exit;
                    MESSAGE(Rec.GenerateIRNOutPutResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."G_IRN Output Response".CreateInStream(Instrm);
                    FileName := Rec."No." + '_IRN Output Payload' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Cancel IRN Sent Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = CancelIRNSent;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("C_IRN Sent Request");
                    if not Rec."C_IRN Sent Request".HasValue then
                        exit;
                    MESSAGE(Rec.CancelIRNSentResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."C_IRN Sent Request".CreateInStream(Instrm);
                    FileName := Rec."No." + '_Cancel Request Payload' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Cancel IRN OutPut Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = CancelIRNOutput;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("C_IRN Output Response");
                    if not Rec."C_IRN Output Response".HasValue then
                        exit;
                    MESSAGE(Rec.CancelIRNOutPutResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."C_IRN Output Response".CreateInStream(Instrm);
                    FileName := Rec."No." + '_Cancel Output Payload' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }

            action("Generate E-Way bill Sent Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = GEWbSendRequest;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("G_E-Way bill Sent Request");
                    if not Rec."G_E-Way bill Sent Request".HasValue then
                        exit;
                    MESSAGE(Rec.GenerateEWayBillSentResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."G_E-Way bill Sent Request".CreateInStream(Instrm);
                    FileName := Rec."No." + '_E-Way Bill Request' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Generate E-Way bill Output Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = GEWbOutPutRequest;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("G_E-Way bill Output Response");
                    if not Rec."G_E-Way bill Output Response".HasValue then
                        exit;
                    MESSAGE(Rec.GenerateEWayBillOutPutResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."G_E-Way bill Output Response".CreateInStream(Instrm);
                    FileName := Rec."No." + '_E-Way bill Output' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Cancel E-Way bill Sent Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = CancelEWBSent;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("E-Way Bill Cancel Request");
                    if not Rec."E-Way Bill Cancel Request".HasValue then
                        exit;
                    MESSAGE(Rec.CancelEWayBillSentResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."E-Way Bill Cancel Request".CreateInStream(Instrm);
                    FileName := Rec."No." + '_Cancel E-Way Bill Request' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
            action("Cancel E-Way bill Output Request")
            {
                ApplicationArea = All;
                Promoted = true;
                Enabled = CancelEWBOutput;
                trigger OnAction()
                begin
                    Rec.CALCFIELDS("E-Way Bill Cancel Output");
                    if not Rec."E-Way Bill Cancel Output".HasValue then
                        exit;
                    MESSAGE(Rec.CancelEWayBillOutPutResponseReadAsText('', TEXTENCODING::UTF8));
                    Rec."E-Way Bill Cancel Output".CreateInStream(Instrm);
                    FileName := Rec."No." + '_Cancel E-Way bill Output' + '.txt';
                    DownloadFromStream(Instrm, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
        }
    }

    var
        Instrm: InStream;
        FileName: Text;
        GEWbSendRequest: Boolean;
        GEWbOutPutRequest: Boolean;
        GIRNSent: Boolean;
        GIRNOutput: Boolean;
        CancelEWBSent: Boolean;
        CancelEWBOutput: Boolean;
        CancelIRNSent: Boolean;
        CancelIRNOutput: Boolean;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("G_E-Way bill Sent Request");
        if not Rec."G_E-Way bill Sent Request".HasValue then
            GEWbSendRequest := false
        else
            GEWbSendRequest := true;
        Rec.CalcFields("G_E-Way bill Output Response");
        if not Rec."G_E-Way bill Output Response".HasValue then
            GEWbOutPutRequest := false
        else
            GEWbOutPutRequest := true;
        Rec.CalcFields("G_IRN Sent Request");
        if not Rec."G_IRN Sent Request".HasValue then
            GIRNSent := false
        else
            GIRNSent := true;
        Rec.CalcFields("G_IRN Output Response");
        if not Rec."G_IRN Output Response".HasValue then
            GIRNOutput := false
        else
            GIRNOutput := true;
        Rec.CalcFields("C_IRN Sent Request");
        if not Rec."C_IRN Sent Request".HasValue then
            CancelIRNSent := false
        else
            CancelIRNSent := true;
        Rec.CalcFields("C_IRN Output Response");
        if not Rec."C_IRN Output Response".HasValue then
            CancelIRNOutput := false
        else
            CancelIRNOutput := true;
        Rec.CalcFields("E-Way Bill Cancel Request");
        if not Rec."E-Way Bill Cancel Request".HasValue then
            CancelEWBSent := false
        else
            CancelEWBSent := true;
        Rec.CalcFields("E-Way Bill Cancel Output");
        if not Rec."E-Way Bill Cancel Output".HasValue then
            CancelEWBOutput := false
        else
            CancelEWBOutput := true;
    end;
}