tableextension 50956 EInvSalesCrMemoHeader extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50160; "APIS_Cancel Remarks"; Enum "Cancel Remarks")
        {
            DataClassification = ToBeClassified;
            Caption = 'Cancel Remarks';
        }
        field(50161; "APIS_Irn Cancel DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Irn Cancel DateTime';
        }
        field(50162; "APIS_LR/RR No."; code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'LR/RR No.';
        }
        field(50163; "APIS_LR/RR Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'LR/RR Date';
        }
        field(50164; "APIS_E-Way Bill Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'E-Way Bill Date Time';
        }
        field(50165; "APIS_E-Way Bill CancelDateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'E-Way Bill Cancel DateTime';
        }
    }
}