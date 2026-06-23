pageextension 60704 "Posted Purch. Inv. Subform Ext" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addbefore(DocAttach)

        {
            action("Distribution")
            {
                ApplicationArea = All;
                Caption = 'Distribution';
                Image = Excel;
                ToolTip = 'This action is for distribution purposes.';
                trigger OnAction()
                var
                lpDistributionOrders:Page "Distribution purch. invoice";
                begin
                    lpDistributionOrders.PurchLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}