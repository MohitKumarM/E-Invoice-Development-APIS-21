pageextension 50154 EInvPostedSalesCrMemo extends "Posted Sales Credit Memo"
{
    layout
    {
        modify("IRN Hash")
        {
            Enabled = false;
        }
        modify("Acknowledgement Date")
        {
            Enabled = false;
        }
        modify("Acknowledgement No.")
        {
            Enabled = false;
        }
        modify("QR Code")
        {
            Enabled = false;
        }

        addafter("Cancel Reason")
        {
            field("Transport Method"; Rec."Transport Method")
            {
                ApplicationArea = all;
            }
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = all;
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = all;
            }
            field("Cancel Remarks"; Rec."APIS_Cancel Remarks")
            {
                ApplicationArea = all;
            }
            field("Irn Cancel DateTime"; Rec."APIS_Irn Cancel DateTime")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("LR/RR No."; Rec."APIS_LR/RR No.")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("LR/RR Date"; Rec."APIS_LR/RR Date")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("E-Way Bill No."; Rec."E-Way Bill No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("E-Way Bill Date Time"; Rec."APIS_E-Way Bill Date Time")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("E-Way Bill Cancel DateTime"; Rec."APIS_E-Way Bill CancelDateTime")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            group("E-Invoice")
            {
                action("Create IRN No.")
                {
                    ApplicationArea = All;
                    Promoted = true;

                    trigger OnAction()
                    var
                        EInvoiceGeneration: Codeunit "E-Invoice Generation";
                    begin
                        if Confirm('Do you want to create IRN No.?', false) then begin
                            if (Rec."GST Customer Type" <> Rec."GST Customer Type"::Unregistered) then begin
                                Clear(EInvoiceGeneration);
                                EInvoiceGeneration.GenerateIRN(Rec."No.", 2, true);
                            end else
                                Error('IRN is not needed for unregistered customer type')
                        end
                    end;
                }
                action("Check Payload")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    trigger OnAction()
                    var
                        EInvoiceGeneration: Codeunit "E-Invoice Generation";
                    begin
                        if Confirm('Do you want to Check IRN Payload ?', false) then begin
                            if (Rec."GST Customer Type" <> Rec."GST Customer Type"::Unregistered) then begin
                                Clear(EInvoiceGeneration);
                                EInvoiceGeneration.GenerateIRN(Rec."No.", 2, false);
                            end else
                                Error('IRN is not needed for unregistered customer type')
                        end
                    end;
                }
                action("E-Invoice Log")
                {
                    ApplicationArea = All;
                    RunObject = page "E-Invoice Log";
                    RunPageLink = "Document Type" = filter('Credit Memo'),
                    "No." = field("No.");
                    Promoted = true;
                }
                action("Cancel Irn")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    trigger OnAction()
                    var
                        EInvoiceGeneration: Codeunit "E-Invoice Generation";
                    begin
                        if Confirm('Do you want to Cancel Irn No.?', false) then begin
                            Rec.TestField("IRN Hash");
                            Rec.TestField("APIS_Irn Cancel DateTime", 0DT);
                            Clear(EInvoiceGeneration);
                            EInvoiceGeneration.CancelIRN(Rec."No.", 2);
                        end
                    end;
                }
                action("Download QR Code")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    trigger OnAction()
                    var
                        Instrm: InStream;
                        FileName: Text;
                    begin
                        rec.CalcFields("E-Invoice QR");
                        rec."E-Invoice QR".CreateInStream(Instrm);
                        FileName := Rec."No." + '.JPG';
                        DownloadFromStream(Instrm, '', '', '', FileName);
                    end;
                }
            }
            group("E-Way Bill")
            {
                action("Generate E-Way Bill")
                {
                    ApplicationArea = All;
                    Visible = false;
                    trigger OnAction()
                    var
                        EWaybillGeneration: Codeunit "E-Way Bill Generartion";
                    begin
                        if Confirm('Do you want to Generate E-Way Bill No.?', false) then begin
                            Rec.TestField("IRN Hash");
                            Rec.TestField("APIS_Irn Cancel DateTime", 0DT);
                            Rec.TestField("E-Way Bill No.", '');
                            Clear(EWaybillGeneration);
                            EWaybillGeneration.GenerateEWayBillFromIRN(Rec."No.", 2);
                        end
                    end;
                }
                action("Cancel E-Way Bill")
                {
                    ApplicationArea = All;
                    Visible = false;
                    trigger OnAction()
                    var
                        EWaybillGeneration: Codeunit "E-Way Bill Generartion";
                    begin
                        if Confirm('Do you want to Canel E-Way Bill No.?', false) then begin
                            Rec.TestField("APIS_E-Way Bill CancelDateTime", 0DT);
                            Rec.TestField("E-Way Bill No.");
                            Clear(EWaybillGeneration);
                            EWaybillGeneration.CancelEWayBill(Rec."No.", 2);
                        end
                    end;
                }
            }
        }
    }
}