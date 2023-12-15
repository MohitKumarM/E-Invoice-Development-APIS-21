table 50023 "E-Invoice Set Up"
{
    DataClassification = ToBeClassified;
    LookupPageId = "E-Invoice Setup";

    fields
    {
        field(1; Primary; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Client ID"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Client Secret"; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "IP Address"; text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Authentication URL"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "E-Invoice URl"; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Round GL Account 1"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Round GL Account 2"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Private Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Private Value"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Private IP"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Cancel E-Way Bill URL"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Download E-Way Bill URL"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Primary)
        {
            Clustered = true;
        }
    }
}