pageextension 60705 "Pst Purch. Cr.Memo Subform Ext" extends "Posted Purch. Cr. Memo Subform"
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
                lpDistributionOrders:Page "Distribution purch. cr. memo";
                begin
                    lpDistributionOrders.PurchLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}