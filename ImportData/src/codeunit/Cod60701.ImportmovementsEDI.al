codeunit 60701 "Import movements EDI"
{
    trigger OnRun()
    var
        lrIntegrationEntry: Record "Integration Entry";
        lIsOK: Boolean;
    begin

        rCompanyInfo.GET;
        rTFSSetup.GET();
        IsOK();

        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE("Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE(Reversed, FALSE);
        rIntegrationEntry.SETRANGE("Inbound creation", TRUE);
        rIntegrationEntry.SETRANGE(Origin, 'STOCK');
        rIntegrationEntry.SETFILTER("Requisition no.", '<>%1|<>%2', 'ENTRADA', '');
        rIntegrationEntry.SETFILTER(Destination, '<>%1', '');
        IF rIntegrationEntry.FINDSET THEN BEGIN
            REPEAT
                ActionDone := InboundCreation;
                IF ActionDone THEN BEGIN
                    rIntegrationEntry."Inbound creation" := FALSE;
                    rIntegrationEntry."Inbound created" := TRUE;
                    rIntegrationEntry.MODIFY(TRUE);
                END;
            UNTIL rIntegrationEntry.NEXT = 0;
            rItemJournalLine.RESET;
            rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
            rItemJournalLine.SETRANGE("Journal Batch Name", 'IMPORT');
            IF NOT rItemJournalLine.ISEMPTY THEN
                CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", rItemJournalLine);
        END;

        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE("Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(post, TRUE);
        rIntegrationEntry.SETRANGE(posted, FALSE);
        rIntegrationEntry.SETRANGE(reversed, FALSE);
        rIntegrationEntry.SETRANGE("Inbound creation", TRUE);
        rIntegrationEntry.SETRANGE(destination, 'STOCK');
        rIntegrationEntry.SETFILTER("Requisition no.", '<>%1', '');
        rIntegrationEntry.SETFILTER(origin, '<>%1|<>%2', 'STOCK', '');
        rIntegrationEntry.SETRANGE("New tyre", FALSE);
        IF rIntegrationEntry.FINDSET THEN BEGIN
            REPEAT
                ActionDone := InboundCreation();
                IF ActionDone THEN BEGIN
                    rIntegrationEntry.Posted := TRUE;
                    IF rIntegrationEntry.Errors THEN BEGIN
                        rIntegrationEntry.Errors := FALSE;
                        rIntegrationEntry.Message := '';
                    END;
                    rIntegrationEntry."Inbound creation" := FALSE;
                    rIntegrationEntry."Inbound created" := TRUE;
                    rIntegrationEntry.MODIFY(TRUE);
                END;
            UNTIL rIntegrationEntry.NEXT = 0;
            rItemJournalLine.RESET;
            rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
            rItemJournalLine.SETRANGE("Journal Batch Name", 'IMPORT');
            IF NOT rItemJournalLine.ISEMPTY THEN
                CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", rItemJournalLine);
        END;

        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE("Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE(Reversed, FALSE);
        rIntegrationEntry.SETFILTER(Destination, '<>%1', '');
        rIntegrationEntry.SETRANGE("Requisition no.", 'ENTRADA');
        IF rIntegrationEntry.FINDSET THEN BEGIN
            rItemJournalLine.RESET;
            rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
            rItemJournalLine.SETRANGE("Journal Batch Name", 'IMPORT');
            IF rItemJournalLine.FINDLAST THEN
                CurLinItem := rItemJournalLine."Line No." + 10
            ELSE
                CurLinItem := 10;
            REPEAT
                IF rItem.GET(rIntegrationEntry.Item) THEN;
                rItemJournalLine.INIT;
                rItemJournalLine.VALIDATE("Journal Template Name", 'SERVIRODA');
                rItemJournalLine.VALIDATE("Journal Batch Name", 'IMPORT');
                rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                rItemJournalLine.VALIDATE("Item No.", rIntegrationEntry.Item);
                rItemJournalLine.VALIDATE("Posting Date", rIntegrationEntry."Entry Date");
                rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Positive Adjmt.");
                rItemJournalLine.VALIDATE("Document No.", rIntegrationEntry."Requisition no.");
                rItemJournalLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                rItemJournalLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                rItemJournalLine.INSERT(TRUE);
                CurLinItem += 10;
                IF rItem."Item Tracking Code" <> '' THEN BEGIN
                    rReservationEntry.RESET;
                    IF rReservationEntry.FINDLAST THEN
                        CurLine := rReservationEntry."Entry No." + 1
                    ELSE
                        CurLine := 1;
                    rReservationEntry.INIT;
                    rReservationEntry.VALIDATE("Entry No.", CurLine);
                    rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                    rReservationEntry.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                    rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                    rReservationEntry.VALIDATE("Creation Date", rIntegrationEntry."Entry Date");
                    rReservationEntry.VALIDATE("Source Type", 83);
                    rReservationEntry.VALIDATE("Source Subtype", 2);
                    rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                    rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                    rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                    rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                    rReservationEntry.VALIDATE(Positive, TRUE);
                    rReservationEntry.VALIDATE("Expected Receipt Date", rItemJournalLine."Posting Date");
                    IF rIntegrationEntry.Destination <> 'STOCK' THEN
                        rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                    ELSE
                        rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
                    rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
                    rReservationEntry.VALIDATE("Qty. to Handle (Base)", rIntegrationEntry.Quantity);
                    rReservationEntry.VALIDATE(Correction, FALSE);
                    IF rIntegrationEntry."Tyre status" <> '' THEN
                        rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                    IF rIntegrationEntry."Tyre mm" <> 0 THEN
                        rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                    rReservationEntry.UpdateItemTracking;
                    rReservationEntry.INSERT(TRUE);
                END;
                rIntegrationEntry.Posted := TRUE;
                IF rIntegrationEntry.Errors THEN BEGIN
                    rIntegrationEntry.Errors := FALSE;
                    rIntegrationEntry.Message := '';
                END;
                rIntegrationEntry.MODIFY(TRUE);
            UNTIL rIntegrationEntry.NEXT = 0;
        END;

        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE(rIntegrationEntry."Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE(Reversed, FALSE);
        rIntegrationEntry.SETFILTER(Destination, '<>%1', '');
        rIntegrationEntry.SETFILTER(Origin, '<>%1', '');
        IF rIntegrationEntry.FINDSET THEN
            REPEAT
                IF rItem.GET(rIntegrationEntry.Item) THEN;
                rIntegrationEntry.Message := '';
                lrIntegrationEntry.RESET;
                lrIntegrationEntry.SETRANGE("Requisition no.", rIntegrationEntry."Requisition no.");
                lrIntegrationEntry.SETRANGE(Errors, TRUE);
                lrIntegrationEntry.SETRANGE(Reversed, FALSE);
                IF lrIntegrationEntry.ISEMPTY THEN BEGIN
                    IF (rIntegrationEntry.Amount = 0) AND NOT (rIntegrationEntry."New tyre") THEN BEGIN
                        IF (rIntegrationEntry.Origin <> 'STOCK') THEN
                            CheckExists(rIntegrationEntry);
                        rItemJournalLine.RESET;
                        rItemJournalLine.SETRANGE("Journal Template Name", 'TRANSF.');
                        rItemJournalLine.SETRANGE("Journal Batch Name", 'SERVIRODA');
                        IF rItemJournalLine.FINDLAST THEN
                            CurLinItem := rItemJournalLine."Line No." + 10
                        ELSE
                            CurLinItem := 10;
                        rItemJournalLine.RESET;
                        rItemJournalLine.INIT;
                        rItemJournalLine.VALIDATE("Journal Template Name", 'TRANSF.');
                        rItemJournalLine.VALIDATE("Journal Batch Name", 'SERVIRODA');
                        rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                        rItemJournalLine.VALIDATE("Item No.", rIntegrationEntry.Item);
                        rItemJournalLine.VALIDATE("Posting Date", rIntegrationEntry."Entry Date");
                        rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::Transfer);
                        rItemJournalLine.VALIDATE("Document No.", rIntegrationEntry."Requisition no.");
                        rItemJournalLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                        rItemJournalLine."Shortcut Dimension 1 Code" := FORMAT(rIntegrationEntry."Vehicle code");
                        rItemJournalLine."New Shortcut Dimension 1 Code" := FORMAT(rIntegrationEntry."Vehicle code");
                        rItemJournalLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                        rItemJournalLine.INSERT(TRUE);
                        CurLinItem += 10;
                        IF rItem."Item Tracking Code" <> '' THEN BEGIN
                            rReservationEntry.RESET;
                            IF rReservationEntry.FINDLAST THEN
                                CurLine := rReservationEntry."Entry No." + 1
                            ELSE
                                CurLine := 1;
                            rReservationEntry.INIT;
                            rReservationEntry.VALIDATE("Entry No.", CurLine);
                            rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                            rReservationEntry.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                            rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                            rReservationEntry.VALIDATE("Creation Date", rIntegrationEntry."Entry Date");
                            rReservationEntry.VALIDATE("Source Type", 83);
                            rReservationEntry.VALIDATE("Source Subtype", 4);
                            rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                            rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                            rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                            rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                            rReservationEntry.VALIDATE("New Serial No.", rIntegrationEntry."Serial number");
                            rReservationEntry.VALIDATE(Positive, FALSE);
                            rReservationEntry.VALIDATE("Shipment Date", rItemJournalLine."Posting Date");
                            IF (rIntegrationEntry.Origin <> 'STOCK') THEN
                                rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                            ELSE
                                rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Origin);
                            IF (rIntegrationEntry.Destination <> 'STOCK') THEN
                                rReservationEntry.VALIDATE("New Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                            ELSE
                                rReservationEntry.VALIDATE("New Lot No.", rIntegrationEntry.Destination);
                            rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity * -1);
                            rReservationEntry.VALIDATE("Qty. to Handle (Base)", rIntegrationEntry.Quantity * -1);
                            rReservationEntry.VALIDATE(Correction, FALSE);
                            IF rIntegrationEntry."Tyre status" <> '' THEN
                                rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                            IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                            rReservationEntry.INSERT(TRUE);
                        END;
                    END ELSE BEGIN
                        IF NOT (rIntegrationEntry."New tyre") THEN BEGIN
                            rItemJournalLine.RESET;
                            rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
                            rItemJournalLine.SETRANGE("Journal Batch Name", 'ABATE');
                            IF rItemJournalLine.FINDLAST THEN
                                CurLinItem := rItemJournalLine."Line No." + 10
                            ELSE
                                CurLinItem := 10;
                            rItemJournalLine.INIT;
                            rItemJournalLine.VALIDATE("Journal Template Name", 'SERVIRODA');
                            rItemJournalLine.VALIDATE("Journal Batch Name", 'ABATE');
                            rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                            rItemJournalLine.VALIDATE("Item No.", rIntegrationEntry.Item);
                            rItemJournalLine.VALIDATE("Posting Date", rIntegrationEntry."Entry Date");
                            rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Negative Adjmt.");
                            rItemJournalLine.VALIDATE("Document No.", rIntegrationEntry."Requisition no.");
                            rItemJournalLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                            rItemJournalLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                            rItemJournalLine.INSERT(TRUE);
                            CurLinItem += 10;
                            IF rItem."Item Tracking Code" <> '' THEN BEGIN
                                rReservationEntry.RESET;
                                IF rReservationEntry.FINDLAST THEN
                                    CurLine := rReservationEntry."Entry No." + 1
                                ELSE
                                    CurLine := 1;
                                rReservationEntry.INIT;
                                rReservationEntry.VALIDATE("Entry No.", CurLine);
                                rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                                rReservationEntry.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                                rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                                rReservationEntry.VALIDATE("Creation Date", rIntegrationEntry."Entry Date");
                                rReservationEntry.VALIDATE("Source Type", 83);
                                rReservationEntry.VALIDATE("Source Subtype", 3);
                                rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                                rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                                rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                                rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                                rReservationEntry.VALIDATE(Positive, FALSE);
                                rReservationEntry.VALIDATE("Shipment Date", rItemJournalLine."Posting Date");
                                IF (rIntegrationEntry.Origin <> 'STOCK') THEN
                                    rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                                ELSE
                                    rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Origin);
                                rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity * -1);
                                rReservationEntry.VALIDATE("Qty. to Handle (Base)", rIntegrationEntry.Quantity * -1);
                                rReservationEntry.VALIDATE(Correction, FALSE);
                                IF rIntegrationEntry."Tyre status" <> '' THEN
                                    rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                                IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                    rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                                rReservationEntry.INSERT(TRUE);
                            END;
                        END;
                        IF rPurchaseLine.GET(rPurchaseLine."Document Type"::Order, rIntegrationEntry."Requisition no.", rIntegrationEntry."Line no.") THEN BEGIN
                            IF (rItem."Item Tracking Code" <> '') THEN BEGIN
                                rReservationEntry.RESET;
                                IF rReservationEntry.FINDLAST THEN
                                    CurLine := rReservationEntry."Entry No." + 1
                                ELSE
                                    CurLine := 1;
                                rReservationEntry.INIT;
                                rReservationEntry.VALIDATE("Entry No.", CurLine);
                                rReservationEntry.VALIDATE("Item No.", rPurchaseLine."No.");
                                rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Surplus);
                                rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                                rReservationEntry.VALIDATE("Source Type", 39);
                                rReservationEntry.VALIDATE("Source Subtype", 1);
                                rReservationEntry.VALIDATE("Source ID", rPurchaseLine."Document No.");
                                rReservationEntry.VALIDATE("Source Ref. No.", rPurchaseLine."Line No.");
                                rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                                rReservationEntry.VALIDATE(Positive, FALSE);
                                IF (rIntegrationEntry.Destination <> 'STOCK') THEN
                                    rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                                ELSE
                                    rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
                                rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
                                IF rIntegrationEntry."Tyre status" <> '' THEN
                                    rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                                IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                    rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                                rReservationEntry.INSERT(TRUE);
                                // IF (rItem."Product Group Code" = 'PNEUS') AND (rItem."Item Category Code" = 'MICHELIN')
                                //    AND (rIntegrationEntry.Origin = 'STOCK') THEN BEGIN
                                //     IF ((rCodigos.GET(rCodigos.Tipo::""Tyre status" Pneus", rIntegrationEntry."Tyre status")) AND (rCodigos.Boleano1)) THEN BEGIN
                                //         rPurchaseLine."Requisitar Pneu" := TRUE;
                                //         rPurchaseLine.VALIDATE("Num. Serie requisitado", rIntegrationEntry."Serial number");
                                //         rPurchaseLine.MODIFY;
                                //     END;
                                // END;
                                rIntegrationEntry.Posted := TRUE;
                                IF rIntegrationEntry.Errors THEN BEGIN
                                    rIntegrationEntry.Errors := FALSE;
                                    rIntegrationEntry.Message := '';
                                END;
                                rIntegrationEntry.MODIFY(TRUE);
                            END;
                        END ELSE BEGIN
                            IF rPurchaseHeader.GET(rPurchaseHeader."Document Type"::Order, rIntegrationEntry."Requisition no.") THEN BEGIN
                                rPurchaseLine.INIT;
                                rPurchaseLine.VALIDATE("Document Type", rPurchaseHeader."Document Type");
                                rPurchaseLine.VALIDATE("Document No.", rPurchaseHeader."No.");
                                rPurchaseLine.VALIDATE("Line No.", rIntegrationEntry."Line no.");
                                rPurchaseLine.VALIDATE("Buy-from Vendor No.", rPurchaseHeader."Buy-from Vendor No.");
                                rPurchaseLine.INSERT(TRUE);
                                rPurchaseLine.VALIDATE(Type, rPurchaseLine.Type::Item);
                                rPurchaseLine.VALIDATE("No.", rIntegrationEntry.Item);
                                rPurchaseLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                                rPurchaseLine.VALIDATE("External description", rIntegrationEntry.Description);
                                rPurchaseLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                                rPurchaseLine.VALIDATE("Direct Unit Cost", rIntegrationEntry.Amount);
                                rPurchaseLine.VALIDATE("Line Discount %", rIntegrationEntry.Discount);
                                rPurchaseLine.VALIDATE("Shortcut Dimension 1 Code", FORMAT(rIntegrationEntry."Vehicle code"));
                                rPurchaseLine.VALIDATE("Analytical date", rPurchaseHeader."Analytical date");
                                rPurchaseLine.VALIDATE("Created Automatically", TRUE);
                                rPurchaseLine.VALIDATE("Requisition sent", TRUE);
                                rPurchaseLine.VALIDATE("Requisition sent in", TODAY);
                                // IF (rItem."Product Group Code" = 'PNEUS') AND (rItem."Item Category Code" = 'MICHELIN')
                                //    AND (rIntegrationEntry.Origin = 'STOCK') THEN BEGIN
                                //     IF ((rCodigos.GET(rCodigos.Tipo::""Tyre status" Pneus", rIntegrationEntry."Tyre status")) AND (rCodigos.Boleano1)) THEN BEGIN
                                //         rPurchaseLine."Requisitar Pneu" := TRUE;
                                //         rPurchaseLine.VALIDATE("Num. Serie requisitado", rIntegrationEntry."Serial number");
                                //         rPurchaseLine.MODIFY;
                                //     END;
                                // END;
                                rPurchaseLine.MODIFY(TRUE);
                                IF (rItem."Item Tracking Code" <> '') THEN BEGIN
                                    rReservationEntry.RESET;
                                    IF rReservationEntry.FINDLAST THEN
                                        CurLine := rReservationEntry."Entry No." + 1
                                    ELSE
                                        CurLine := 1;
                                    rReservationEntry.INIT;
                                    rReservationEntry.VALIDATE("Entry No.", CurLine);
                                    rReservationEntry.VALIDATE("Item No.", rPurchaseLine."No.");
                                    rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Surplus);
                                    rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                                    rReservationEntry.VALIDATE("Source Type", 39);
                                    rReservationEntry.VALIDATE("Source Subtype", 1);
                                    rReservationEntry.VALIDATE("Source ID", rPurchaseLine."Document No.");
                                    rReservationEntry.VALIDATE("Source Ref. No.", rPurchaseLine."Line No.");
                                    rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                                    rReservationEntry.VALIDATE(Positive, FALSE);
                                    IF (rIntegrationEntry.Destination <> 'STOCK') THEN
                                        rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                                    ELSE
                                        rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
                                    rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
                                    IF rIntegrationEntry."Tyre status" <> '' THEN
                                        rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                                    IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                        rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                                    rReservationEntry.INSERT(TRUE);
                                END;
                            END;
                        END;
                    END;
                    rIntegrationEntry.Posted := TRUE;
                    IF rIntegrationEntry.Errors THEN BEGIN
                        rIntegrationEntry.Errors := FALSE;
                        rIntegrationEntry.Message := '';
                    END;
                    rIntegrationEntry.MODIFY(TRUE);
                END;
            UNTIL rIntegrationEntry.NEXT = 0;

        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE(rIntegrationEntry."Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE(Reversed, FALSE);
        rIntegrationEntry.SETFILTER(Origin, '=%1', '');
        rIntegrationEntry.SETFILTER("Requisition no.", '<>%1', 'ABATE');
        IF rIntegrationEntry.FINDSET THEN
            REPEAT
                IF rItem.GET(rIntegrationEntry.Item) THEN;
                lrIntegrationEntry.RESET;
                lrIntegrationEntry.SETRANGE("Requisition no.", rIntegrationEntry."Requisition no.");
                lrIntegrationEntry.SETRANGE(Reversed, FALSE);
                lrIntegrationEntry.SETRANGE(Errors, TRUE);
                IF lrIntegrationEntry.ISEMPTY THEN BEGIN
                    IF rPurchaseLine.GET(rPurchaseLine."Document Type"::Order, rIntegrationEntry."Requisition no.", rIntegrationEntry."Line no.") THEN BEGIN
                        IF (rItem."Item Tracking Code" <> '') THEN BEGIN
                            rReservationEntry.RESET;
                            IF rReservationEntry.FINDLAST THEN
                                CurLine := rReservationEntry."Entry No." + 1
                            ELSE
                                CurLine := 1;
                            rReservationEntry.INIT;
                            rReservationEntry.VALIDATE("Entry No.", CurLine);
                            rReservationEntry.VALIDATE("Item No.", rPurchaseLine."No.");
                            rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Surplus);
                            // IF (rItem."Product Group Code" = 'PNEUS') AND (rItem."Item Category Code" = 'MICHELIN')
                            //    AND (rIntegrationEntry.Origin = 'STOCK') THEN BEGIN
                            //     IF ((rCodigos.GET(rCodigos.Tipo::""Tyre status" Pneus", rIntegrationEntry."Tyre status")) AND (rCodigos.Boleano1)) THEN BEGIN
                            //         //            rReservationEntry.VALIDATE("Location Code", 'MICHELIN');
                            //         rPurchaseLine."Requisitar Pneu" := TRUE;
                            //         rPurchaseLine.VALIDATE("Num. Serie requisitado", rIntegrationEntry."Serial number");
                            //         rPurchaseLine.MODIFY;
                            //     END ELSE
                            //         rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                            // END ELSE
                            //     rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                            rReservationEntry.VALIDATE("Source Type", 39);
                            rReservationEntry.VALIDATE("Source Subtype", 1);
                            rReservationEntry.VALIDATE("Source ID", rPurchaseLine."Document No.");
                            rReservationEntry.VALIDATE("Source Ref. No.", rPurchaseLine."Line No.");
                            rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                            rReservationEntry.VALIDATE(Positive, FALSE);
                            IF (rIntegrationEntry.Destination <> 'STOCK') THEN
                                //          rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry."Vehicle code"+'-'+rIntegrationEntry.Destination)
                                rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                            ELSE
                                rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
                            rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
                            IF rIntegrationEntry."Tyre status" <> '' THEN
                                rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                            IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                            rReservationEntry.INSERT(TRUE);
                            rIntegrationEntry.Posted := TRUE;
                            IF rIntegrationEntry.Errors THEN BEGIN
                                rIntegrationEntry.Errors := FALSE;
                                rIntegrationEntry.Message := '';
                            END;
                            rIntegrationEntry.MODIFY(TRUE);
                        END;
                    END ELSE BEGIN
                        IF rPurchaseHeader.GET(rPurchaseHeader."Document Type"::Order, rIntegrationEntry."Requisition no.") THEN BEGIN
                            rPurchaseLine.INIT;
                            rPurchaseLine.VALIDATE("Document Type", rPurchaseHeader."Document Type");
                            rPurchaseLine.VALIDATE("Document No.", rPurchaseHeader."No.");
                            rPurchaseLine.VALIDATE("Line No.", rIntegrationEntry."Line no.");
                            rPurchaseLine.VALIDATE("Buy-from Vendor No.", rPurchaseHeader."Buy-from Vendor No.");
                            rPurchaseLine.INSERT(TRUE);
                            rPurchaseLine.VALIDATE(Type, rPurchaseLine.Type::Item);
                            rPurchaseLine.VALIDATE("No.", rIntegrationEntry.Item);
                            // IF (rItem."Product Group Code" = 'PNEUS') AND (rItem."Item Category Code" = 'MICHELIN')
                            //    AND (rIntegrationEntry.Origin = 'STOCK') THEN BEGIN
                            //     IF ((rCodigos.GET(rCodigos.Tipo::""Tyre status" Pneus", rIntegrationEntry."Tyre status")) AND (rCodigos.Boleano1)) THEN BEGIN
                            //         rPurchaseLine."Requisitar Pneu" := TRUE;
                            //         rPurchaseLine.VALIDATE("Num. Serie requisitado", rIntegrationEntry."Serial number");
                            //         rPurchaseLine.MODIFY;
                            //     END ELSE
                            //         rPurchaseLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                            // END ELSE
                            //     rPurchaseLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                            rPurchaseLine.VALIDATE("External description", rIntegrationEntry.Description);
                            rPurchaseLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                            rPurchaseLine.VALIDATE("Direct Unit Cost", rIntegrationEntry.Amount);
                            rPurchaseLine.VALIDATE("Line Discount %", rIntegrationEntry.Discount);
                            rPurchaseLine.VALIDATE("Shortcut Dimension 1 Code", FORMAT(rIntegrationEntry."Vehicle code"));
                            rPurchaseLine.VALIDATE("Analytical date", rPurchaseHeader."Analytical date");
                            rPurchaseLine.VALIDATE("Created Automatically", TRUE);
                            rPurchaseLine.VALIDATE("Requisition sent", TRUE);
                            rPurchaseLine.VALIDATE("Requisition sent in", TODAY);
                            rPurchaseLine.MODIFY(TRUE);
                            IF (rItem."Item Tracking Code" <> '') THEN BEGIN
                                rReservationEntry.RESET;
                                IF rReservationEntry.FINDLAST THEN
                                    CurLine := rReservationEntry."Entry No." + 1
                                ELSE
                                    CurLine := 1;
                                rReservationEntry.INIT;
                                rReservationEntry.VALIDATE("Entry No.", CurLine);
                                rReservationEntry.VALIDATE("Item No.", rPurchaseLine."No.");
                                rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Surplus);
                                // IF (rItem."Product Group Code" = 'PNEUS') AND (rItem."Item Category Code" = 'MICHELIN') THEN BEGIN
                                //     IF ((rCodigos.GET(rCodigos.Tipo::""Tyre status" Pneus", rIntegrationEntry."Tyre status")) AND (rCodigos.Boleano1)) THEN BEGIN
                                //         //              rReservationEntry.VALIDATE("Location Code", 'MICHELIN');
                                //         rPurchaseLine."Requisitar Pneu" := TRUE;
                                //         rPurchaseLine.VALIDATE("Num. Serie requisitado", rIntegrationEntry."Serial number");
                                //         rPurchaseLine.MODIFY;
                                //     END ELSE
                                //         rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                                // END ELSE
                                //     rReservationEntry.VALIDATE("Location Code", rPurchaseLine."Location Code");
                                rReservationEntry.VALIDATE("Source Type", 39);
                                rReservationEntry.VALIDATE("Source Subtype", 1);
                                rReservationEntry.VALIDATE("Source ID", rPurchaseLine."Document No.");
                                rReservationEntry.VALIDATE("Source Ref. No.", rPurchaseLine."Line No.");
                                rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                                rReservationEntry.VALIDATE(Positive, FALSE);
                                IF (rIntegrationEntry.Destination <> 'STOCK') THEN
                                    rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                                ELSE
                                    rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
                                rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
                                IF rIntegrationEntry."Tyre status" <> '' THEN
                                    rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                                IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                    rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                                rReservationEntry.INSERT(TRUE);
                            END;
                            rIntegrationEntry.Posted := TRUE;
                            IF rIntegrationEntry.Errors THEN BEGIN
                                rIntegrationEntry.Errors := FALSE;
                                rIntegrationEntry.Message := '';
                            END;
                            rIntegrationEntry.MODIFY(TRUE);
                        END;
                    END;
                END;
            UNTIL rIntegrationEntry.NEXT = 0;


        rIntegrationEntry.RESET;
        IF Req <> '' THEN
            IF Seq = 0 THEN
                rIntegrationEntry.SETRANGE("Requisition no.", Req)
            ELSE BEGIN
                rIntegrationEntry.SETRANGE("Requisition no.", Req);
                rIntegrationEntry.SETRANGE(rIntegrationEntry."Entry No.", Seq)
            END;
        rIntegrationEntry.SETRANGE(Errors, FALSE);
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE(Reversed, FALSE);
        rIntegrationEntry.SETFILTER(Destination, '=%1', '');
        rIntegrationEntry.SETRANGE("Requisition no.", 'ABATE');
        IF rIntegrationEntry.FINDSET THEN BEGIN
            rItemJournalLine.RESET;
            rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
            rItemJournalLine.SETRANGE("Journal Batch Name", 'ABATE');
            IF rItemJournalLine.FINDLAST THEN
                CurLinItem := rItemJournalLine."Line No." + 10
            ELSE
                CurLinItem := 10;
            REPEAT
                IF rItem.GET(rIntegrationEntry.Item) THEN;
                rItemJournalLine.INIT;
                rItemJournalLine.VALIDATE("Journal Template Name", 'SERVIRODA');
                rItemJournalLine.VALIDATE("Journal Batch Name", 'ABATE');
                rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                rItemJournalLine.VALIDATE("Item No.", rIntegrationEntry.Item);
                rItemJournalLine.VALIDATE("Posting Date", rIntegrationEntry."Entry Date");
                rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Negative Adjmt.");
                rItemJournalLine.VALIDATE("Document No.", rIntegrationEntry."Requisition no.");
                rItemJournalLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                rItemJournalLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
                rItemJournalLine.INSERT(TRUE);
                CurLinItem += 10;
                IF rItem."Item Tracking Code" <> '' THEN BEGIN
                    rReservationEntry.RESET;
                    IF rReservationEntry.FINDLAST THEN
                        CurLine := rReservationEntry."Entry No." + 1
                    ELSE
                        CurLine := 1;
                    rReservationEntry.INIT;
                    rReservationEntry.VALIDATE("Entry No.", CurLine);
                    rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                    rReservationEntry.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
                    rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                    rReservationEntry.VALIDATE("Creation Date", rIntegrationEntry."Entry Date");
                    rReservationEntry.VALIDATE("Source Type", 83);
                    rReservationEntry.VALIDATE("Source Subtype", 3);
                    rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                    rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                    rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                    rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
                    rReservationEntry.VALIDATE(Positive, FALSE);
                    rReservationEntry.VALIDATE("Shipment Date", rItemJournalLine."Posting Date");
                    IF rIntegrationEntry.Origin <> 'STOCK' THEN
                        rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
                    ELSE
                        rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Origin);
                    rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity * -1);
                    rReservationEntry.VALIDATE("Qty. to Handle (Base)", rIntegrationEntry.Quantity * -1);
                    rReservationEntry.VALIDATE(Correction, FALSE);
                    IF rIntegrationEntry."Tyre status" <> '' THEN
                        rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
                    IF rIntegrationEntry."Tyre mm" <> 0 THEN
                        rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
                    rReservationEntry.UpdateItemTracking;
                    rReservationEntry.INSERT(TRUE);
                END;
                rIntegrationEntry.Posted := TRUE;
                IF rIntegrationEntry.Errors THEN BEGIN
                    rIntegrationEntry.Errors := FALSE;
                    rIntegrationEntry.Message := '';
                END;
                rIntegrationEntry.MODIFY(TRUE);
            UNTIL rIntegrationEntry.NEXT = 0;
        END;


        rItemJournalLine.RESET;
        rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
        rItemJournalLine.SETRANGE("Document No.", 'ABATE');
        rItemJournalLine.SETFILTER("Item No.", '<>%1', '');
        IF NOT rItemJournalLine.ISEMPTY THEN
            MESSAGE('Existem movimentos de Abate pendentes de registo');
    end;

    procedure Parameters(pRequisition: Code[20]; pSequence: Integer)
    var
        myInt: Integer;
    begin

        Req := pRequisition;
        Seq := pSequence;
    end;

    procedure CheckExists(pRec: Record "Integration Entry")
    var
        lrItemLedgerEntry: Record "Item Ledger Entry";
        lrItemJournalLine: record "Item Journal Line";
        lrReservationEntry: Record "Reservation Entry";
    begin

        lrItemLedgerEntry.RESET;
        lrItemLedgerEntry.SETCURRENTKEY("Lot No.");
        lrItemLedgerEntry.SETRANGE("Lot No.", FORMAT(pRec."Vehicle code") + '-' + prec.Origin);
        lrItemLedgerEntry.SETRANGE("Serial No.", prec."Serial number");
        IF lrItemLedgerEntry.FINDLAST THEN
            IF lrItemLedgerEntry.Positive THEN BEGIN
                IF lrItemLedgerEntry."Item No." <> prec.Item THEN BEGIN
                    IF COPYSTR(lrItemLedgerEntry."Item No.", 3, 7) = COPYSTR(prec.Item, 1, 7) THEN BEGIN
                        TextMessage := 'O nº Serie ' + prec."Serial number" + ' do produto ' + prec.Item + 'foi encontrado no produto ' +
                                    lrItemLedgerEntry."Item No." + '. Pretende efectuar correccao?';
                        IF CONFIRM(TextMessage, TRUE) THEN BEGIN
                            rItemJournalLine.RESET;
                            rItemJournalLine.SETRANGE("Journal Template Name", 'PRODUTO');
                            rItemJournalLine.SETRANGE("Journal Batch Name", 'GENÉRICO');
                            IF rItemJournalLine.FINDLAST THEN
                                CurLinItem := rItemJournalLine."Line No." + 10
                            ELSE
                                CurLinItem := 10;
                            rItemJournalLine.INIT;
                            rItemJournalLine.VALIDATE("Journal Template Name", 'PRODUTO');
                            rItemJournalLine.VALIDATE("Journal Batch Name", 'GENÉRICO');
                            rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                            rItemJournalLine.VALIDATE("Item No.", lrItemLedgerEntry."Item No.");
                            rItemJournalLine.VALIDATE("Posting Date", prec."Entry Date");
                            rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Negative Adjmt.");
                            rItemJournalLine.VALIDATE("Document No.", prec."Requisition no.");
                            rItemJournalLine.VALIDATE("Location Code", prec."Vendor Center");
                            rItemJournalLine.VALIDATE(Quantity, prec.Quantity);
                            rItemJournalLine.INSERT(TRUE);
                            CurLinItem += 10;
                            rReservationEntry.RESET;
                            IF rReservationEntry.FINDLAST THEN
                                CurLine := rReservationEntry."Entry No." + 1
                            ELSE
                                CurLine := 1;
                            rReservationEntry.INIT;
                            rReservationEntry.VALIDATE("Entry No.", CurLine);
                            rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                            rReservationEntry.VALIDATE("Location Code", prec."Vendor Center");
                            rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                            rReservationEntry.VALIDATE("Creation Date", prec."Entry Date");
                            rReservationEntry.VALIDATE("Source Type", 83);
                            rReservationEntry.VALIDATE("Source Subtype", 3);
                            rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                            rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                            rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                            rReservationEntry.VALIDATE("Serial No.", prec."Serial number");
                            rReservationEntry.VALIDATE(Positive, FALSE);
                            rReservationEntry.VALIDATE("Shipment Date", rItemJournalLine."Posting Date");
                            rReservationEntry.VALIDATE("Lot No.", FORMAT(prec."Vehicle code"));
                            rReservationEntry.VALIDATE("Quantity (Base)", prec.Quantity * -1);
                            rReservationEntry.VALIDATE("Qty. to Handle (Base)", prec.Quantity * -1);
                            rReservationEntry.VALIDATE(Correction, FALSE);
                            IF rIntegrationEntry."Tyre status" <> '' THEN
                                rReservationEntry.VALIDATE("Tyre status", prec."Tyre status");
                            IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                rReservationEntry.mm := ROUND(prec."Tyre mm", 1.0, '<');
                            rReservationEntry.INSERT(TRUE);
                            rItemJournalLine.INIT;
                            rItemJournalLine.VALIDATE("Journal Template Name", 'PRODUTO');
                            rItemJournalLine.VALIDATE("Journal Batch Name", 'GENÉRICO');
                            rItemJournalLine.VALIDATE("Line No.", CurLinItem);
                            rItemJournalLine.VALIDATE("Item No.", prec.Item);
                            rItemJournalLine.VALIDATE("Posting Date", prec."Entry Date");
                            rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Positive Adjmt.");
                            rItemJournalLine.VALIDATE("Document No.", prec."Requisition no.");
                            rItemJournalLine.VALIDATE("Location Code", prec."Vendor Center");
                            rItemJournalLine.VALIDATE(Quantity, prec.Quantity);
                            rItemJournalLine.INSERT(TRUE);
                            CurLinItem += 10;
                            rReservationEntry.RESET;
                            IF rReservationEntry.FINDLAST THEN
                                CurLine := rReservationEntry."Entry No." + 1
                            ELSE
                                CurLine := 1;
                            rReservationEntry.INIT;
                            rReservationEntry.VALIDATE("Entry No.", CurLine);
                            rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
                            rReservationEntry.VALIDATE("Location Code", prec."Vendor Center");
                            rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
                            rReservationEntry.VALIDATE("Creation Date", prec."Entry Date");
                            rReservationEntry.VALIDATE("Source Type", 83);
                            rReservationEntry.VALIDATE("Source Subtype", 2);
                            rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
                            rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
                            rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
                            rReservationEntry.VALIDATE("Serial No.", prec."Serial number");
                            rReservationEntry.VALIDATE(Positive, TRUE);
                            rReservationEntry.VALIDATE("Expected Receipt Date", rItemJournalLine."Posting Date");
                            rReservationEntry.VALIDATE("Lot No.", FORMAT(prec."Vehicle code"));
                            rReservationEntry.VALIDATE("Quantity (Base)", prec.Quantity);
                            rReservationEntry.VALIDATE("Qty. to Handle (Base)", prec.Quantity);
                            rReservationEntry.VALIDATE(Correction, FALSE);
                            IF rIntegrationEntry."Tyre status" <> '' THEN
                                rReservationEntry.VALIDATE("Tyre status", prec."Tyre status");
                            IF rIntegrationEntry."Tyre mm" <> 0 THEN
                                rReservationEntry.mm := ROUND(prec."Tyre mm", 1.0, '<');
                            rReservationEntry.UpdateItemTracking;
                            rReservationEntry.INSERT(TRUE);
                        END;
                    END;
                END;
            END;
    end;

    procedure IsOK()
    var
        WithError: Boolean;
        l2PurchaseHeader: Record "Purchase Header";
        l2PurchaseLine: Record "Purchase Line";
        l2Item: Record Item;
        l2ItemTracking: Record "Item Tracking Code";
        l2ItemLedgerEntry: Record "Item Ledger Entry";
        l2PurchasePrice: Record "Purchase Price";
        l2PurchaseDiscount: Record "Purchase Line Discount";
        l2PurchasePrice2: Record "Purchase Price";
        lrVendorCenter: Record Location;
        AmountDif: Decimal;
    begin

        WithError := FALSE;
        //
        rIntegrationEntry.RESET;
        rIntegrationEntry.SETRANGE(Post, TRUE);
        rIntegrationEntry.SETRANGE(Posted, FALSE);
        rIntegrationEntry.SETRANGE("Inbound creation", FALSE);
        IF Req <> '' THEN
            rIntegrationEntry.SETRANGE("Requisition no.", Req);
        IF rIntegrationEntry.FINDSET THEN
            REPEAT
                rIntegrationEntry.Message := '';
                IF rIntegrationEntry."Requisition no." = '' THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'Nao foi indicado o nº de "Requisition no."';
                    rIntegrationEntry.MODIFY(TRUE);
                END ELSE BEGIN
                    IF (rIntegrationEntry."Requisition no." <> 'ABATE') AND (rIntegrationEntry."Requisition no." <> 'ENTRADA') THEN BEGIN
                        l2PurchaseHeader.RESET;
                        l2PurchaseHeader.SETRANGE("No.", rIntegrationEntry."Requisition no.");
                        IF l2PurchaseHeader.ISEMPTY THEN BEGIN
                            rIntegrationEntry.Errors := TRUE;
                            IF rIntegrationEntry.Message = '' THEN
                                rIntegrationEntry.Message := 'A "Requisition no." nao existe';
                            rIntegrationEntry.MODIFY(TRUE);
                            WithError := TRUE;
                        END;
                    END;
                END;
                IF rIntegrationEntry."Entry Date" = 0D THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'Nao foi indicada a data do Movimento';
                    rIntegrationEntry.MODIFY(TRUE);
                    WithError := TRUE;
                END;
                IF rIntegrationEntry."Line no." = 0 THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'Nao foi indicado o nº de linha';
                    rIntegrationEntry.MODIFY(TRUE);
                    WithError := TRUE;
                END ELSE BEGIN
                    l2PurchaseLine.RESET;
                    l2PurchaseLine.SETRANGE("No.", rIntegrationEntry."Requisition no.");
                    l2PurchaseLine.SETRANGE("Line No.", rIntegrationEntry."Line no.");
                    IF NOT l2PurchaseLine.ISEMPTY THEN BEGIN
                        rIntegrationEntry.Errors := TRUE;
                        IF rIntegrationEntry.Message = '' THEN
                            rIntegrationEntry.Message := 'A linha ' + FORMAT(rIntegrationEntry."Line no.") + 'já existe';
                        rIntegrationEntry.MODIFY(TRUE);
                        WithError := TRUE;
                    END;
                END;
                IF rIntegrationEntry.Item = '' THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'Nao foi indicado o codigo de artigo';
                    rIntegrationEntry.MODIFY(TRUE);
                    WithError := TRUE;
                END ELSE BEGIN
                    IF l2Item.GET(rIntegrationEntry.Item) THEN BEGIN
                        IF rIntegrationEntry."Serial number" <> '' THEN BEGIN
                            IF l2Item."Item Tracking Code" <> '' THEN BEGIN
                                IF l2ItemTracking.GET(l2Item."Item Tracking Code") THEN BEGIN
                                    IF (l2ItemTracking."SN Specific Tracking" = FALSE) AND (l2ItemTracking."SN Info. Inbound Must Exist" = FALSE)
                                       AND (l2ItemTracking."SN Purchase Inbound Tracking" = FALSE) THEN BEGIN
                                        rIntegrationEntry.Errors := TRUE;
                                        IF rIntegrationEntry.Message = '' THEN
                                            rIntegrationEntry.Message := 'Utilizacao de nº série mas o produto nao permite nº série - ' + rIntegrationEntry.Item;
                                        rIntegrationEntry.MODIFY(TRUE);
                                        WithError := TRUE;
                                    END;
                                END ELSE BEGIN
                                    rIntegrationEntry.Errors := TRUE;
                                    IF rIntegrationEntry.Message = '' THEN
                                        rIntegrationEntry.Message := 'Codigo tipo rastreio nao está definido - ' + rIntegrationEntry.Item;
                                    rIntegrationEntry.MODIFY(TRUE);
                                    WithError := TRUE;
                                END;
                            END ELSE BEGIN
                                rIntegrationEntry.Errors := TRUE;
                                IF rIntegrationEntry.Message = '' THEN
                                    rIntegrationEntry.Message := 'Utilizacao de nº série mas o produto nao permite nº série - ' + rIntegrationEntry.Item;
                                rIntegrationEntry.MODIFY(TRUE);
                                WithError := TRUE;
                            END;
                        END;
                    END;
                END;
                IF (rIntegrationEntry."Vendor Center" = '') AND ((rIntegrationEntry."Serial number" <> '') OR (rIntegrationEntry.Origin <>
                   '') OR (rIntegrationEntry.Destination <> '')) THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'A linha ' + FORMAT(rIntegrationEntry."Line no.") + ' nao tem Localizacao';
                    rIntegrationEntry.MODIFY(TRUE);
                    WithError := TRUE;
                END ELSE BEGIN
                    IF (rIntegrationEntry."Vendor Center" <> '') AND NOT lrVendorCenter.GET(rIntegrationEntry."Vendor Center") THEN BEGIN
                        rIntegrationEntry.Errors := TRUE;
                        IF rIntegrationEntry.Message = '' THEN
                            rIntegrationEntry.Message := 'O codigo de Localizacao ' + rIntegrationEntry."Vendor Center" + ' nao existe';
                        rIntegrationEntry.MODIFY(TRUE);
                        WithError := TRUE;
                    END;
                END;
                IF rIntegrationEntry.Quantity = 0 THEN BEGIN
                    rIntegrationEntry.Errors := TRUE;
                    IF rIntegrationEntry.Message = '' THEN
                        rIntegrationEntry.Message := 'Movimento com quantidade 0 - Linha ' + FORMAT(rIntegrationEntry."Line no.");
                    rIntegrationEntry.MODIFY(TRUE);
                    WithError := TRUE;
                END;
                IF rIntegrationEntry."Serial number" <> '' THEN BEGIN
                    IF (rIntegrationEntry.Origin <> '') AND NOT (rIntegrationEntry."New tyre") THEN BEGIN
                        l2ItemLedgerEntry.RESET;
                        l2ItemLedgerEntry.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", "Expiration Date",
                                                  "Lot No.", "Serial No.");
                        l2ItemLedgerEntry.SETRANGE("Item No.", rIntegrationEntry.Item);
                        l2ItemLedgerEntry.SETRANGE("Serial No.", rIntegrationEntry."Serial number");
                        l2ItemLedgerEntry.SETRANGE("Location Code", rIntegrationEntry."Vendor Center");
                        IF NOT l2ItemLedgerEntry.FINDSET THEN BEGIN
                            rIntegrationEntry.Errors := TRUE;
                            IF rIntegrationEntry.Message = '' THEN
                                rIntegrationEntry.Message := 'O nºsérie indicado nao existe em stock - Linha ' + FORMAT(rIntegrationEntry."Line no.");
                            rIntegrationEntry.MODIFY(TRUE);
                            WithError := TRUE;
                        END ELSE BEGIN
                            l2ItemLedgerEntry.CALCSUMS(Quantity);
                            IF l2ItemLedgerEntry.Quantity <= 0 THEN BEGIN
                                rIntegrationEntry.Errors := TRUE;
                                IF rIntegrationEntry.Message = '' THEN
                                    rIntegrationEntry.Message := 'Nao há stock disponivel para o nºsérie ' + rIntegrationEntry."Serial number" + ' Linha ' +
                                                            FORMAT(rIntegrationEntry."Line no.");
                                rIntegrationEntry.MODIFY(TRUE);
                                WithError := TRUE;
                            END;
                        END;
                    END;
                    IF (rIntegrationEntry.Origin <> '') AND (rIntegrationEntry.Destination = '') AND (rIntegrationEntry."Requisition no." <> 'ABATE') THEN BEGIN
                        l2ItemLedgerEntry.RESET;
                        l2ItemLedgerEntry.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", "Expiration Date",
                                                  "Lot No.", "Serial No.");
                        l2ItemLedgerEntry.SETRANGE("Item No.", rIntegrationEntry.Item);
                        l2ItemLedgerEntry.SETRANGE("Serial No.", rIntegrationEntry."Serial number");
                        IF l2ItemLedgerEntry.FINDSET THEN BEGIN
                            l2ItemLedgerEntry.CALCSUMS(Quantity);
                            IF l2ItemLedgerEntry.Quantity > 0 THEN BEGIN
                                rIntegrationEntry.Errors := TRUE;
                                IF rIntegrationEntry.Message = '' THEN
                                    rIntegrationEntry.Message := 'O nºsérie ' + rIntegrationEntry."Serial number" + ' já existe em stock - Linha '
                                                            + FORMAT(rIntegrationEntry."Line no.");
                                rIntegrationEntry.MODIFY(TRUE);
                                WithError := TRUE;
                            END;
                        END ELSE BEGIN
                            IF l2ItemLedgerEntry.Quantity <= 0 THEN BEGIN
                                rIntegrationEntry.Errors := TRUE;
                                IF rIntegrationEntry.Message = '' THEN
                                    rIntegrationEntry.Message := 'Nao há stock disponivel para o nºsérie ' + rIntegrationEntry."Serial number" +
                                                            ' Linha ' + FORMAT(rIntegrationEntry."Line no.");
                                rIntegrationEntry.MODIFY(TRUE);
                                WithError := TRUE;
                            END;
                        END;
                    END;
                END;
                IF (rIntegrationEntry."Requisition no." <> 'ENTRADA') AND (rIntegrationEntry."Requisition no." <> 'ABATE') AND
                   (rTFSSetup."Serviroda vendor no." <> '') THEN BEGIN
                    l2PurchasePrice.SETRANGE("Item No.", rIntegrationEntry.Item);
                    l2PurchasePrice.SETRANGE("Vendor No.", rTFSSetup."Serviroda vendor no.");
                    IF l2PurchasePrice.ISEMPTY THEN BEGIN
                        rIntegrationEntry.Errors := TRUE;
                        IF rIntegrationEntry.Message = '' THEN
                            rIntegrationEntry.Message := 'Nao existe relacao artigo/fornecedor definida - ' + rTFSSetup."Serviroda vendor no.";
                        rIntegrationEntry.MODIFY(TRUE);
                        WithError := TRUE;
                    END;
                END;
                l2PurchasePrice2.RESET;
                l2PurchasePrice2.SETRANGE("Item No.", rIntegrationEntry.Item);
                l2PurchasePrice2.SETRANGE("Vendor No.", rTFSSetup."Serviroda vendor no.");
                l2PurchasePrice2.SETFILTER("Starting Date", '<=%1', rIntegrationEntry."Entry Date");
                l2PurchasePrice2.SETFILTER("Ending Date", '=%1|>=%2', 0D, rIntegrationEntry."Entry Date");
                IF l2PurchasePrice2.FINDLAST THEN BEGIN
                    IF (rIntegrationEntry.Amount <> l2PurchasePrice2."Direct Unit Cost") AND (rIntegrationEntry."Requisition no." <> 'ABATE') THEN BEGIN
                        IF l2Item.GET(rIntegrationEntry.Item) THEN BEGIN
                            IF l2Item."Price validation" = FALSE THEN BEGIN
                                AmountDif := ABS(rIntegrationEntry.Amount - l2PurchasePrice2."Direct Unit Cost");
                                IF AmountDif > 0.1 THEN BEGIN
                                    IF rIntegrationEntry.Message = '' THEN
                                        rIntegrationEntry.Message := 'Valor diferente da "Requisition no.". Item ' + rPurchaseLine."No." + ', Valor "Requisition no." ' +
                                                                FORMAT(l2PurchasePrice2."Direct Unit Cost") + ', ' + 'Valor Ficheiro ' +
                                                                FORMAT(rIntegrationEntry.Amount);
                                    IF rIntegrationEntry.Amount <> 0 THEN BEGIN
                                        rIntegrationEntry.Errors := TRUE;
                                        WithError := TRUE;
                                    END;
                                END;
                            END;
                        END;
                        rIntegrationEntry.MODIFY(TRUE);
                    END;
                END ELSE BEGIN
                    IF rIntegrationEntry."Requisition no." <> 'ABATE' THEN BEGIN
                        rIntegrationEntry.Errors := TRUE;
                        IF rIntegrationEntry.Message = '' THEN
                            rIntegrationEntry.Message := 'Nao existe preço definido. Item = ' + rIntegrationEntry.Item;
                        rIntegrationEntry.MODIFY(TRUE);
                        WithError := TRUE;
                    END;
                END;
                IF rIntegrationEntry.Amount <> 0 THEN BEGIN
                    l2PurchaseDiscount.RESET;
                    l2PurchaseDiscount.SETRANGE("Item No.", rIntegrationEntry.Item);
                    l2PurchaseDiscount.SETRANGE("Vendor No.", rTFSSetup."Serviroda vendor no.");
                    l2PurchaseDiscount.SETFILTER("Starting Date", '<=%1', rIntegrationEntry."Entry Date");
                    l2PurchaseDiscount.SETFILTER("Ending Date", '=%1|>=%2', 0D, rIntegrationEntry."Entry Date");
                    IF l2PurchaseDiscount.FINDLAST THEN BEGIN
                        IF (rIntegrationEntry.Discount <> l2PurchaseDiscount."Line Discount %") AND (rIntegrationEntry."Requisition no." <> 'ABATE') THEN BEGIN
                            IF rIntegrationEntry.Message = '' THEN
                                rIntegrationEntry.Message := 'Percentagem de desconto do produto ' + rIntegrationEntry.Item + '  diferente. Desconto "Requisition no." ' +
                                                        FORMAT(l2PurchaseDiscount."Line Discount %") + ', Desconto Ficheiro ' + FORMAT(rIntegrationEntry.Discount);
                            IF rIntegrationEntry.Discount <> 0 THEN BEGIN
                                rIntegrationEntry.Errors := TRUE;
                                WithError := TRUE;
                            END;
                            rIntegrationEntry.MODIFY(TRUE);
                        END;
                    END;
                END;
            UNTIL rIntegrationEntry.NEXT = 0;
    end;

    procedure InboundCreation(): Boolean
    var
        l3PurchasePrice: Record "Purchase Price";
        l3PurchaseDiscount: Record "Purchase Line Discount";
    begin

        rItemJournalLine.RESET;
        rItemJournalLine.SETRANGE("Journal Template Name", 'SERVIRODA');
        rItemJournalLine.SETRANGE("Journal Batch Name", 'IMPORT');
        IF rItemJournalLine.FINDLAST THEN
            CurLinItem := rItemJournalLine."Line No." + 10
        ELSE
            CurLinItem := 10;
        IF rItem.GET(rIntegrationEntry.Item) THEN;
        rItemJournalLine.INIT;
        rItemJournalLine.VALIDATE("Journal Template Name", 'SERVIRODA');
        rItemJournalLine.VALIDATE("Journal Batch Name", 'IMPORT');
        rItemJournalLine.VALIDATE("Line No.", CurLinItem);
        rItemJournalLine.VALIDATE("Item No.", rIntegrationEntry.Item);
        rItemJournalLine.VALIDATE("Posting Date", rIntegrationEntry."Entry Date");
        rItemJournalLine.VALIDATE("Entry Type", rItemJournalLine."Entry Type"::"Positive Adjmt.");
        rItemJournalLine.VALIDATE("Document No.", rIntegrationEntry."Requisition no.");
        rItemJournalLine.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
        rItemJournalLine.VALIDATE(Quantity, rIntegrationEntry.Quantity);
        IF (rIntegrationEntry.Origin <> 'STOCK') AND (rIntegrationEntry.Destination = 'STOCK') THEN
            rItemJournalLine.Description := 'Stock carro anterior'
        ELSE
            IF (rIntegrationEntry.Origin = 'STOCK') AND (rIntegrationEntry.Destination <> 'STOCK') THEN BEGIN
                rItemJournalLine.Description := 'A faturar';
                l3PurchasePrice.RESET;
                l3PurchasePrice.SETRANGE("Item No.", rIntegrationEntry.Item);
                l3PurchasePrice.SETRANGE("Vendor No.", rTFSSetup."Michelin vendor no.");
                l3PurchasePrice.SETFILTER("Starting Date", '<=%1', rIntegrationEntry."Entry Date");
                l3PurchasePrice.SETFILTER("Ending Date", '=%1|>=%2', 0D, rIntegrationEntry."Entry Date");
                IF l3PurchasePrice.FINDLAST THEN
                    IF rIntegrationEntry.Amount <> 0 THEN
                        rItemJournalLine."Unit Cost" := l3PurchasePrice."Direct Unit Cost";
                l3PurchaseDiscount.RESET;
                l3PurchaseDiscount.SETRANGE("Item No.", rIntegrationEntry.Item);
                l3PurchaseDiscount.SETRANGE("Vendor No.", rTFSSetup."Michelin vendor no.");
                l3PurchaseDiscount.SETFILTER("Starting Date", '<=%1', rIntegrationEntry."Entry Date");
                l3PurchaseDiscount.SETFILTER("Ending Date", '=%1|>=%2', 0D, rIntegrationEntry."Entry Date");
                IF l3PurchaseDiscount.FINDLAST THEN
                    IF rIntegrationEntry.Discount <> 0 THEN
                        rItemJournalLine.VALIDATE("Discount Amount", rItemJournalLine.Amount - (rItemJournalLine.Amount * (l3PurchaseDiscount."Line Discount %" / 100)));
            END;
        rItemJournalLine.VALIDATE("Shortcut Dimension 1 Code", FORMAT(rIntegrationEntry."Vehicle code"));
        rItemJournalLine.INSERT(TRUE);
        CurLinItem += 10;
        IF rItem."Item Tracking Code" <> '' THEN BEGIN
            rReservationEntry.RESET;
            IF rReservationEntry.FINDLAST THEN
                CurLine := rReservationEntry."Entry No." + 1
            ELSE
                CurLine := 1;
            rReservationEntry.INIT;
            rReservationEntry.VALIDATE("Entry No.", CurLine);
            rReservationEntry.VALIDATE("Item No.", rItemJournalLine."Item No.");
            rReservationEntry.VALIDATE("Location Code", rIntegrationEntry."Vendor Center");
            rReservationEntry.VALIDATE("Reservation Status", rReservationEntry."Reservation Status"::Prospect);
            rReservationEntry.VALIDATE("Creation Date", rIntegrationEntry."Entry Date");
            rReservationEntry.VALIDATE("Source Type", 83);
            rReservationEntry.VALIDATE("Source Subtype", 2);
            rReservationEntry.VALIDATE("Source ID", rItemJournalLine."Journal Template Name");
            rReservationEntry.VALIDATE("Source Batch Name", rItemJournalLine."Journal Batch Name");
            rReservationEntry.VALIDATE("Source Ref. No.", rItemJournalLine."Line No.");
            rReservationEntry.VALIDATE("Serial No.", rIntegrationEntry."Serial number");
            rReservationEntry.VALIDATE(Positive, TRUE);
            rReservationEntry.VALIDATE("Expected Receipt Date", rItemJournalLine."Posting Date");
            IF rIntegrationEntry.Destination <> 'STOCK' THEN
                rReservationEntry.VALIDATE("Lot No.", FORMAT(rIntegrationEntry."Vehicle code"))
            ELSE
                rReservationEntry.VALIDATE("Lot No.", rIntegrationEntry.Destination);
            rReservationEntry.VALIDATE("Quantity (Base)", rIntegrationEntry.Quantity);
            rReservationEntry.VALIDATE("Qty. to Handle (Base)", rIntegrationEntry.Quantity);
            rReservationEntry.VALIDATE(Correction, FALSE);
            IF rIntegrationEntry."Tyre status" <> '' THEN
                rReservationEntry.VALIDATE("Tyre status", rIntegrationEntry."Tyre status");
            IF rIntegrationEntry."Tyre mm" <> 0 THEN
                rReservationEntry.mm := ROUND(rIntegrationEntry."Tyre mm", 1.0, '<');
            rReservationEntry.UpdateItemTracking;
            rReservationEntry.INSERT(TRUE);
        END;
        EXIT(TRUE);
    end;

    var
        rCompanyInfo: Record "Company Information";
        rTFSSetup: Record "TFS Setup";
        rItemJournalLine: Record "Item Journal Line";
        rPurchaseHeader: Record "Purchase Header";
        rPurchaseLine: Record "Purchase Line";
        rReservationEntry: Record "Reservation Entry";
        rIntegrationEntry: Record "Integration Entry";
        rVehicles: Record Vehicle;
        rItem: Record Item;
        TextMessage: Text[150];
        Req: Code[20];
        Seq: Integer;
        ActionDone: Boolean;
        CurLinItem: Integer;
        CurLine: Integer;
}