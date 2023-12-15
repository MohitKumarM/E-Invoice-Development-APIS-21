page 50210 "E-Invoice Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "E-Invoice Set Up";

    layout
    {
        area(Content)
        {
            group("E-Invoice Setup")
            {
                field("Client ID"; Rec."Client ID")
                {
                    ToolTip = 'Specifies the value of the Client ID field.';
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ToolTip = 'Specifies the value of the Client Secret field.';
                }
                field("IP Address"; Rec."IP Address")
                {
                    ToolTip = 'Specifies the value of the IP Address field.';
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ToolTip = 'Specifies the value of the Authentication URL field.';
                }
                field("E-Invoice URl"; Rec."E-Invoice URl")
                {
                    ToolTip = 'Specifies the value of the E-Invoice URl field.';
                }
                field("Private Key"; Rec."Private Key")
                {
                    ApplicationArea = all;
                }
                field("Private Value"; Rec."Private Value")
                {
                    ApplicationArea = all;
                }
                field("Private IP"; Rec."Private IP")
                {
                    ApplicationArea = all;
                }
                field("Cancel E-Way Bill URL"; Rec."Cancel E-Way Bill URL")
                {
                    ApplicationArea = all;
                }
                field("Download E-Way Bill URL"; Rec."Download E-Way Bill URL")
                {
                    ApplicationArea = all;
                }
                field("Round GL Account 1"; Rec."Round GL Account 1")
                {
                    ToolTip = 'Specifies the value of the Round GL Account 1 field.';
                }
                field("Round GL Account 2"; Rec."Round GL Account 2")
                {
                    ToolTip = 'Specifies the value of the Round GL Account 2 field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsertUserSetup)
            {
                Promoted = true;
                trigger OnAction()
                var
                    UserSetup: Record "User Setup";
                begin
                    if UserSetup.Get(UserId) then begin
                        UserSetup."Allow UserId" := true;
                        UserSetup.Modify();
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}