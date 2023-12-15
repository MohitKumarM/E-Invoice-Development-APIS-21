pageextension 50151 EInvUnitOfMeasure extends "Units of Measure"
{
    layout
    {
        addafter(Description)
        {
            field("UOM For E Invoicing"; Rec."APIS_UOM For E Invoicing")
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