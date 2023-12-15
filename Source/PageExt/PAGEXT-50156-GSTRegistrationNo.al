pageextension 50156 GSTRegsitrationNo extends "GST Registration Nos."
{
    layout
    {
        addafter(Description)
        {
            field("User Name"; Rec."APIS_User Name")
            {
                ApplicationArea = all;
            }
            field(Password; Rec.APIS_Password)
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}