pageextension 50153 EInvPostedSalesInvoice extends "Posted Sales Invoice"
{
    layout
    {
        moveafter("IRN Hash"; "Transport Method")
        modify("Transport Method")
        {
            Editable = true;
        }
        modify("Vehicle No.")
        {
            Editable = true;
        }
        modify("Vehicle Type")
        {
            Editable = true;
        }

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
        modify("E-Way Bill No.")
        {
            Enabled = false;
        }
        addafter("Cancel Reason")
        {
            field("Cancel Remarks"; Rec."APIS_Cancel Remarks")
            {
                ApplicationArea = all;
            }
            field("Irn Cancel DateTime"; Rec."APIS_Irn Cancel DateTime")
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
        addafter(Invoice)
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
                                EInvoiceGeneration.GenerateIRN(Rec."No.", 1, true);
                            end else
                                Error('IRN is not needed for unregistered customer type')
                        end;
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
                        if Confirm('Do you want to Check IRN Payload?', false) then begin
                            if (Rec."GST Customer Type" <> Rec."GST Customer Type"::Unregistered) then begin
                                Clear(EInvoiceGeneration);
                                EInvoiceGeneration.GenerateIRN(Rec."No.", 1, false);
                            end else
                                Error('IRN is not needed for unregistered customer type')
                        end
                    end;
                }
                action("E-Invoice Log")
                {
                    ApplicationArea = All;
                    RunObject = page "E-Invoice Log";
                    RunPageLink = "Document Type" = filter('Invoice'),
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
                            EInvoiceGeneration.CancelIRN(Rec."No.", 1);
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
                        rec.CalcFields("E-Invoce QR");
                        rec."E-Invoce QR".CreateInStream(Instrm);
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
                    Promoted = true;
                    trigger OnAction()
                    var
                        EWaybillGeneration: Codeunit "E-Way Bill Generartion";
                    begin
                        if Confirm('Do you want to Generate E-Way Bill No.?', false) then begin
                            Rec.TestField("IRN Hash");
                            Rec.TestField("APIS_Irn Cancel DateTime", 0DT);
                            Rec.TestField("E-Way Bill No.", '');
                            Clear(EWaybillGeneration);
                            EWaybillGeneration.GenerateEWayBillFromIRN(Rec."No.", 1);
                        end
                    end;
                }
                action("Download E-Way Bill")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    trigger OnAction()
                    var
                        EWaybillGeneration: Codeunit "E-Way Bill Generartion";
                    begin
                        Clear(EWaybillGeneration);
                        Rec.TestField("E-Way Bill No.");
                        EWaybillGeneration.DownloadEwayBillPDF(rec."No.", 1);
                    end;
                }
                action("Cancel E-Way Bill")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    trigger OnAction()
                    var
                        EWaybillGeneration: Codeunit "E-Way Bill Generartion";
                    begin
                        if Confirm('Do you want to Cancel E-Way Bill No.?', false) then begin
                            Rec.TestField("APIS_E-Way Bill CancelDateTime", 0DT);
                            Rec.TestField("E-Way Bill No.");
                            Clear(EWaybillGeneration);
                            EWaybillGeneration.CancelEWayBill(Rec."No.", 1);
                        end
                    end;
                }
            }
        }
    }
}