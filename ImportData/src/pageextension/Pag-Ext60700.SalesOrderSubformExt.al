pageextension 60700 "Sales Order Subform Ext" extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addbefore("Item Availability by")

        {
            action("Distribution")
            {
                ApplicationArea = All;
                Caption = 'Distribution';
                Image = Excel;
                ToolTip = 'This action is for distribution purposes.';
                trigger OnAction()
                var
                lpDistributionOrders:Page "Distribution for sales orders";
                begin
                    lpDistributionOrders.SalesLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}