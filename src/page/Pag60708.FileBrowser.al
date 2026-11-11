page 60708 "File Browser"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BLOB File";
    //    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'File Browser';


    layout
    {

        area(Content)
        {
            repeater(ItemList)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the file.';
                    Caption = 'Name';
                    trigger OnDrillDown()
                    var
                        FileBrowser: Page "File Browser";
                    begin
                        if Rec.Type = Rec.Type::Folder then begin
                            FileBrowser.SetCurrentFolder(Rec.ID);
                            FileBrowser.RunModal();
                        end;
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(NewFolder)
            {
                ApplicationArea = All;
                Caption = 'New Folder';
                Image = Journal;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.CreateNewFolder(CurrentFolder, 'New Folder');
                end;
            }
            action(NewFile)
            {
                ApplicationArea = All;
                Caption = 'New File';
                Image = BeginningText;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.CreateNewFile(CurrentFolder, 'New File');
                end;
            }
            action(importFile)
            {
                ApplicationArea = All;
                Caption = 'Import File';
                Image = Import;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.ImportFile(CurrentFolder);
                end;
            }
        }
    }
    var
        CurrentFolder: Integer;



    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        UpdateList();
    end;

    procedure SetCurrentFolder(CurrFolder: Integer)
    var
        myInt: Integer;
    begin
        CurrentFolder := CurrFolder;
    end;

    local procedure UpdateList()
    var
        myInt: Integer;
    begin
        Rec.Reset();
        Rec.SetRange("Parent ID", CurrentFolder);
        CurrPage.Update();
    end;


}