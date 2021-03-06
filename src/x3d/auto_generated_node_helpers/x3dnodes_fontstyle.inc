{ -*- buffer-read-only: t -*-

  Copyright 2015-2020 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated node properties.

  Do not edit this file manually!
  To add new properties:
  - add them to the text files in tools/internal/x3d-nodes-to-pascal/nodes-specification/ ,
  - and regenerate include files by running x3d-nodes-to-pascal .

  The documentation for properties should go to x3dnodes_documentation.txt . }

{$ifdef read_interface}

  strict private
    function GetHorizontal: Boolean;
    procedure SetHorizontal(const Value: Boolean);
{$ifndef CASTLE_SLIM_NODES}
    function GetLanguage: String;
    procedure SetLanguage(const Value: String);
{$endif not CASTLE_SLIM_NODES}
{$ifndef CASTLE_SLIM_NODES}
    function GetLeftToRight: Boolean;
    procedure SetLeftToRight(const Value: Boolean);
{$endif not CASTLE_SLIM_NODES}
    function GetSize: Single;
    procedure SetSize(const Value: Single);
    function GetSpacing: Single;
    procedure SetSpacing(const Value: Single);
{$ifndef CASTLE_SLIM_NODES}
    function GetTopToBottom: Boolean;
    procedure SetTopToBottom(const Value: Boolean);
{$endif not CASTLE_SLIM_NODES}
  public
    { X3D field "horizontal". } { }
    property Horizontal: Boolean read GetHorizontal write SetHorizontal;
{$ifndef CASTLE_SLIM_NODES}
    { X3D field "language". } { }
    property Language: String read GetLanguage write SetLanguage;
{$endif not CASTLE_SLIM_NODES}
{$ifndef CASTLE_SLIM_NODES}
    { X3D field "leftToRight". } { }
    property LeftToRight: Boolean read GetLeftToRight write SetLeftToRight;
{$endif not CASTLE_SLIM_NODES}
    { X3D field "size". } { }
    property Size: Single read GetSize write SetSize;
    { X3D field "spacing". } { }
    property Spacing: Single read GetSpacing write SetSpacing;
{$ifndef CASTLE_SLIM_NODES}
    { X3D field "topToBottom". } { }
    property TopToBottom: Boolean read GetTopToBottom write SetTopToBottom;
{$endif not CASTLE_SLIM_NODES}

{$endif read_interface}

{$ifdef read_implementation}

{ TFontStyleNode ----------------------------------------------- }

function TFontStyleNode.GetHorizontal: Boolean;
begin
  Result := FdHorizontal.Value;
end;

procedure TFontStyleNode.SetHorizontal(const Value: Boolean);
begin
  FdHorizontal.Send(Value);
end;

{$ifndef CASTLE_SLIM_NODES}
function TFontStyleNode.GetLanguage: String;
begin
  Result := FdLanguage.Value;
end;

procedure TFontStyleNode.SetLanguage(const Value: String);
begin
  FdLanguage.Send(Value);
end;

{$endif not CASTLE_SLIM_NODES}
{$ifndef CASTLE_SLIM_NODES}
function TFontStyleNode.GetLeftToRight: Boolean;
begin
  Result := FdLeftToRight.Value;
end;

procedure TFontStyleNode.SetLeftToRight(const Value: Boolean);
begin
  FdLeftToRight.Send(Value);
end;

{$endif not CASTLE_SLIM_NODES}
function TFontStyleNode.GetSize: Single;
begin
  Result := FdSize.Value;
end;

procedure TFontStyleNode.SetSize(const Value: Single);
begin
  FdSize.Send(Value);
end;

function TFontStyleNode.GetSpacing: Single;
begin
  Result := FdSpacing.Value;
end;

procedure TFontStyleNode.SetSpacing(const Value: Single);
begin
  FdSpacing.Send(Value);
end;

{$ifndef CASTLE_SLIM_NODES}
function TFontStyleNode.GetTopToBottom: Boolean;
begin
  Result := FdTopToBottom.Value;
end;

procedure TFontStyleNode.SetTopToBottom(const Value: Boolean);
begin
  FdTopToBottom.Send(Value);
end;

{$endif not CASTLE_SLIM_NODES}
{$endif read_implementation}
