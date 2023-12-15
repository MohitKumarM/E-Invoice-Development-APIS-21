tableextension 50955 EInvSalesInvoiceHeader extends "Sales Invoice Header"
{
    fields
    {
        field(50160; "APIS_Cancel Remarks"; Enum "Cancel Remarks")
        {
            Caption = 'Cancel Remarks';
            DataClassification = ToBeClassified;
        }
        field(50161; "APIS_Irn Cancel DateTime"; DateTime)
        {
            Caption = 'Irn Cancel DateTime';
            DataClassification = ToBeClassified;
        }
        field(50162; "APIS_E-Way Bill Date Time"; DateTime)
        {
            Caption = 'E-Way Bill Date Time';
            DataClassification = ToBeClassified;
        }
        field(50163; "APIS_E-Way Bill CancelDateTime"; DateTime)
        {
            Caption = 'E-Way Bill Cancel DateTime';
            DataClassification = ToBeClassified;
        }
    }
}