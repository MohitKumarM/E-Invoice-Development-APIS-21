tableextension 50194 EInvTransferShipmentHeader extends "Transfer Shipment Header"
{
    fields
    {
        field(50160; "APIS_QR Code"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
            Caption = 'QR Code';
        }
        field(50161; "APIS_IRN Hash"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'IRN Hash';
        }
        field(50162; "APIS_Acknowledgement No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Acknowledgement No.';
        }
        field(50163; "APIS_Acknowledgement Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Acknowledgement Date';
        }
        field(50164; "APIS_Cancel Remarks"; Enum "Cancel Remarks")
        {
            DataClassification = ToBeClassified;
            Caption = 'Cancel Remarks';
        }
        field(50165; "APIS_Cancel Reason"; Enum "e-Invoice Cancel Reason")
        {
            DataClassification = ToBeClassified;
            Caption = 'Cancel Reason';
        }
        field(50166; "APIS_Irn Cancel DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Irn Cancel DateTime';
        }
        field(50167; "APIS_E-Way Bill Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'E-Way Bill Date Time';
        }
        field(50168; "APIS_E-Way Bill No."; Text[50])
        {
            Caption = 'E-Way Bill No.';
            DataClassification = CustomerContent;
        }
        field(50169; "APIS_E-Way Bill CancelDateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'E-Way Bill Cancel DateTime';
        }
    }
}