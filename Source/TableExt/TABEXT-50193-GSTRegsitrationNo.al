tableextension 50193 EInvGSTRegistration extends "GST Registration Nos."
{
    fields
    {
        field(50160; "APIS_User Name"; text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User Name';
        }
        field(50161; "APIS_Password"; text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Password';
        }
    }
}