pageextension 60702 "Pst Sales Cr.Memo Subform Ext" extends "Posted Sales Cr. Memo Subform"
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
                lpDistributionOrders:Page "Distribution for sales cr.memo";
                begin
                    lpDistributionOrders.SalesLine(Rec);
                    lpDistributionOrders.Run();
                end;
            }
        }
    }
}