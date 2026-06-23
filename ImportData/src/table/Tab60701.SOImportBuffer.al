table 60701 "SO Import Buffer"
{
    Caption = 'SO Import Buffer';

    fields
    {
        field(1; "Batch Name"; Code[10])
        {
            Caption = 'Batch Name';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "File Name"; Text[50])
        {
            Caption = 'File Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "Sheet Name"; Text[30])
        {
            Caption = 'Sheet Name';
            DataClassification = CustomerContent;
        }
        field(5; "Imported Date"; Date)
        {
            Caption = 'Imported Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Imported Time"; Time)
        {
            Caption = 'Imported Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(9; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(11; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(12; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(13; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(14; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(16; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
            DataClassification = CustomerContent;
        }
        field(17; "Dimension 1"; Code[20])
        {
            Caption = 'Dimension 1';
            DataClassification = CustomerContent;
        }
        field(18; "Dimension 2"; Code[20])
        {
            Caption = 'Dimension 2';
            DataClassification = CustomerContent;
        }
        field(19; "Dimension 3"; Code[20])
        {
            Caption = 'Dimension 3';
            DataClassification = CustomerContent;
        }
        field(20; "Dimension 4"; Code[20])
        {
            Caption = 'Dimension 5';
            DataClassification = CustomerContent;
        }
        field(21; "Dimension 5"; Code[20])
        {
            Caption = 'Dimension 5';
            DataClassification = CustomerContent;
        }
        field(22; Responsable; Code[20])
        {
            Caption = 'Responsable';
            DataClassification = CustomerContent;
        }
        field(23; "Item"; Code[20])
        {
            Caption = 'Item';
            DataClassification = CustomerContent;
        }
        field(24; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Batch Name", "Line No.")
        {
        }
    }
}