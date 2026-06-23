pageextension 60703 "Purchase Order Subform Ext" extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addbefore("F&unctions")

        {
            action("Distribution")
            {
                ApplicationArea = All;
                Caption = 'Distribution';
                Image = Excel;
                ToolTip = 'This action is for distribution purposes.';
                trigger OnAction()
                var
                lpDistributionOrders:Page "Distribution for purch. order";
                begin
                    lpDistributionOrders.PurchLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}