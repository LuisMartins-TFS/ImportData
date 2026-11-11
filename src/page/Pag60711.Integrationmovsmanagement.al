page 60711 "Integration movs. management"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Integration Entry";
    SourceTableView = sorting("Entry No.");
    InsertAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Requisition no."; Rec."Requisition no.")
                {
                    ToolTip = 'Specifies the value of the Requisition field.';

                }
                field("Line no."; Rec."Line no.")
                {
                    ToolTip = 'Specifies the value of the Line no. field.';

                }
                field(Date; Rec."Entry Date")
                {
                    ToolTip = 'Specifies the value of the Entry Date field.';

                }
                field(Item; Rec.Item)
                {
                    ToolTip = 'Specifies the value of the Item field.';

                }
                field(Workshop; Rec."Vendor Center")
                {
                    ToolTip = 'Specifies the value of the Vendor Center field.';

                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';

                }
                field("Quantity"; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';

                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';

                }
                field("VAT %"; Rec."Vat Tax")
                {
                    ToolTip = 'Specifies the value of the Vat Tax field.';
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies the value of the Discount field.';

                }
                field("Vehicle code"; Rec."Vehicle code")
                {
                    ToolTip = 'Specifies the value of the Vehicle code field.';

                }
                field("Serial no."; Rec."Serial number")
                {
                    ToolTip = 'Specifies the value of the Serial number field.';

                }
                field("Tyre status"; Rec."Tyre status")
                {
                    ToolTip = 'Specifies the value of the Tyre status field.';
                    Visible = false;
                }
                field("Tyre mm"; Rec."Tyre mm")
                {
                    ToolTip = 'Specifies the value of the Tyre mm field.';
                    Visible = false;
                }
                field(Origin; Rec.Origin)
                {
                    ToolTip = 'Specifies the value of the Origin field.';

                }
                field(Destination; Rec.Destination)
                {
                    ToolTip = 'Specifies the value of the Destination field.';

                }
                field(Situation; Rec.Situation)
                {
                    ToolTip = 'Specifies the value of the Situation field.';
                    Visible = false;
                }
                field(Post; rec.Post)
                {
                    ToolTip = 'Specifies the value of the Post field.';

                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies the value of the Posted field.';
                    trigger OnValidate()
                    begin
                        CreateEntryOnPush();
                    end;
                }
                field("Inbound creation"; Rec."Inbound creation")
                {
                    ToolTip = 'Specifies the value of the Inbound creation field.';

                }
                field("New tyre"; Rec."New tyre")
                {
                    ToolTip = 'Specifies the value of the New tyre field.';

                }
                field(Reversed; Rec.Reversed)
                {
                    ToolTip = 'Specifies the value of the Reversed field.';

                }
                field(Errors; Rec.Errors)
                {
                    ToolTip = 'Specifies the value of the Errors field.';

                }
                field(Message; Rec.Message)
                {
                    ToolTip = 'Specifies the value of the Message field.';

                }
                field("Manufacturer code"; Rec."Manufacturer code")
                {
                    ToolTip = 'Specifies the value of the Manufacturer code field.';

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = Open;
                ToolTip = 'Reopens the selected entry.';

                trigger OnAction()
                var
                    lrecPurchHeader: Record "Purchase Header";
                    lrecPurchLine: Record "Purchase Line";
                    lJournalLine: Record "Item Journal Line";
                    lrecReserve: Record "Reservation Entry";
                    Integrado: Boolean;
                begin
                    lrecPurchHeader.RESET;
                    lrecPurchHeader.SETRANGE("Document Type", lrecPurchHeader."Document Type"::Order);
                    lrecPurchHeader.SETRANGE("No.", Rec."Requisition no.");
                    IF NOT lrecPurchHeader.FINDSET THEN
                        ERROR('Nao existe a requisiçao %1!')
                    ELSE
                        IF lrecPurchHeader."Order situation" <> lrecPurchHeader."Order situation"::"Requisition sent" THEN
                            ERROR('O estado actual da requisiçao nao permite alterações!');

                    lrecPurchLine.RESET;
                    lrecPurchLine.SETRANGE("Document Type", lrecPurchLine."Document Type"::Order);
                    lrecPurchLine.SETRANGE("Document No.", Rec."Requisition no.");
                    lrecPurchLine.SETFILTER("Quantity Received", '<>%1', 0);
                    IF NOT lrecPurchLine.ISEMPTY THEN
                        ERROR('Já existem linhas confirmadas para a requisiçao %1!', Rec."Requisition no.");

                    lrecPurchLine.RESET;
                    lrecPurchLine.SETRANGE("Document Type", lrecPurchLine."Document Type"::Order);
                    lrecPurchLine.SETRANGE("Document No.", Rec."Requisition no.");
                    lrecPurchLine.SETFILTER("Quantity Invoiced", '<>%1', 0);
                    IF NOT lrecPurchLine.ISEMPTY THEN
                        ERROR('Já existem linhas facturadas para a requisiçao %1!', Rec."Requisition no.");

                    lJournalLine.RESET;
                    lJournalLine.SETRANGE("Document No.", Rec."Requisition no.");
                    IF lJournalLine.FINDSET THEN
                        IF CONFIRM('Existem movimentos de diário por registar! Pretende anular esses movimentos?', TRUE) THEN BEGIN
                            REPEAT
                                lrecReserve.RESET;
                                lrecReserve.SETRANGE("Source ID", lJournalLine."Journal Template Name");
                                lrecReserve.SETRANGE("Source Batch Name", lJournalLine."Journal Batch Name");
                                lrecReserve.SETRANGE("Source Ref. No.", lJournalLine."Line No.");
                                IF lrecReserve.FINDSET THEN
                                    REPEAT
                                        lrecReserve.DELETE(TRUE);
                                    UNTIL lrecReserve.NEXT = 0;
                                lJournalLine.DELETE(TRUE);
                            UNTIL lJournalLine.NEXT = 0;
                        END ELSE
                            ERROR('Processo cancelado!');

                    lrecPurchLine.RESET;
                    lrecPurchLine.SETRANGE("Document Type", lrecPurchLine."Document Type"::Order);
                    lrecPurchLine.SETRANGE("Document No.", Rec."Requisition no.");
                    lrecPurchLine.SETFILTER("No.", '<>%1', '');
                    IF lrecPurchLine.FINDSET THEN
                        REPEAT
                            lrecReserve.RESET;
                            lrecReserve.SETRANGE("Source ID", lrecPurchLine."Document No.");
                            lrecReserve.SETRANGE("Source Ref. No.", lrecPurchLine."Line No.");
                            IF lrecReserve.FINDSET THEN
                                REPEAT
                                    lrecReserve.DELETE(TRUE);
                                UNTIL lrecReserve.NEXT = 0;
                            lrecPurchLine.DELETE(TRUE);
                        UNTIL lrecPurchLine.NEXT = 0;
                    Integrado := FALSE;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action(SeeCorrections)
            {
                ApplicationArea = All;
                Caption = 'See Corrections';
                Image = SelectEntries;
                ToolTip = 'See corrections.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Item Journal";

            }
            action(SeeTransfers)
            {
                ApplicationArea = All;
                Caption = 'See Transfers';
                Image = TransferOrder;
                ToolTip = 'See transfers.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Item Reclass. Journal";
            }
        
            action(PostRequisition)
            {
                ApplicationArea = All;
                Caption = 'Post Requisition';
                Image = Post;
                ToolTip = 'Posts the requisition.';

                trigger OnAction()
                begin

                    IF (Rec."Requisition no." = 'ABATE') OR (Rec."Requisition no." = 'ENTRADA') THEN
                        cduPost.Parameters(Rec."Requisition no.", Rec."Entry No.")
                    ELSE
                        cduPost.Parameters(Rec."Requisition no.", 0);
                    cduPost.RUN;
                end;
            }
        }
    }
    trigger OnInit()
    var
        myInt: Integer;
    begin
        CorrectionsVisible := TRUE;
        TransfersVisible := TRUE;
        PostDocVisible := TRUE;
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        IF Batch THEN BEGIN
            Rec.SETRANGE("Requisition no.", DocumentNo);
            Rec.SETRANGE(Post);
            Rec.SETRANGE(Reversed, FALSE);
            PostDocVisible := FALSE;
            TransfersVisible := FALSE;
            CorrectionsVisible := FALSE;
        END ELSE BEGIN
            RequisitionNo := '';
            DocDate := 0D;
            GetRecFilters;
            SetRecFilters;
        END;
    end;

    procedure GetRecFilters()
    var
        myInt: Integer;
    begin
        IF Rec.GETFILTERS <> '' THEN BEGIN
            DocumentNo := Rec.GETFILTER("Requisition no.");
            VehicleNo := Rec.GETFILTER("Vehicle code");
            SelectDate := Rec.GETFILTER("Entry Date");
            SelectErrors := false;
            SelectReversed := FALSE;
            IF Batch THEN
                SelectPosted := true
            ELSE
                SelectPosted := false;
        END ELSE BEGIN
            SelectDate := '..' + FORMAT(WORKDATE);
            DocumentNo := '';
            VehicleNo := '';
            SelectErrors := false;
            SelectPosted := false;
            SelectReversed := FALSE;
        END;
    end;

    procedure SetRecFilters()
    var
        myInt: Integer;
    begin
        IF DocumentNo <> '' THEN
            Rec.SETFILTER("Requisition no.", RequisitionNo)
        ELSE
            Rec.SETRANGE("Requisition no.");
        IF SelectDate <> '' THEN
            Rec.SETFILTER("Entry Date", SelectDate)
        ELSE
            Rec.SETRANGE("Entry Date");
        IF VehicleNo <> '' THEN
            Rec.SETFILTER("Vehicle code", VehicleNo)
        ELSE
            Rec.SETRANGE("Vehicle code");
        IF SelectErrors THEN
            Rec.SETRANGE(Errors, TRUE)
        ELSE
            Rec.SETRANGE(Errors, FALSE);
        IF SelectPosted THEN
            Rec.SETRANGE(Posted, TRUE)
        ELSE
            Rec.SETRANGE(Posted, FALSE);
        IF SelectReversed THEN
            Rec.SETRANGE(Reversed, true)
        ELSE
            Rec.SETRANGE(Reversed, false);
        IF Batch THEN BEGIN
            Rec.SETRANGE("Entry Date");
            Rec.SETRANGE(Posted);
        END;
        CurrPage.UPDATE(FALSE);
    end;

    procedure GetCaption()
    begin
        GetRecFilters();
    end;

    procedure Parameters(pRequisition: Code[20])
    begin
        DocumentNo := pRequisition;
        Batch := TRUE;
    end;

    local procedure CreateEntryOnPush()
    begin
        if Rec."Inbound created" then
            ERROR('Inbound already created for this entry.');
    end;

    var
        CorrectionsVisible: Boolean;
        TransfersVisible: Boolean;
        PostDocVisible: Boolean;
        Batch: Boolean;
        DocumentNo: Code[20];
        RequisitionNo: Code[20];
        DocDate: Date;
        VehicleNo: Code[20];
        SelectDate: Text[30];
        SelectErrors: Boolean;
        SelectReversed: Boolean;
        SelectPosted: Boolean;
        cduPost: codeunit "Import movements EDI";
}