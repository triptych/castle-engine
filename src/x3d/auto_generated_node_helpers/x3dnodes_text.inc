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
    function GetMaxExtent: Single;
    procedure SetMaxExtent(const Value: Single);
    function GetMaxDisplayChars: Integer;
    procedure SetMaxDisplayChars(const Value: Integer);
  public
    { Set X3D field "length". } { }
    procedure SetLength(const Value: array of Single);
    { Set X3D field "length". } { }
    procedure SetLength(const Value: TSingleList);
    { X3D field "maxExtent". } { }
    property MaxExtent: Single read GetMaxExtent write SetMaxExtent;
    { X3D field "maxDisplayChars". } { }
    property MaxDisplayChars: Integer read GetMaxDisplayChars write SetMaxDisplayChars;
    { Set X3D field "string". } { }
    procedure SetString(const Value: array of string);
    { Set X3D field "string". } { }
    procedure SetString(const Value: TCastleStringList);

{$endif read_interface}

{$ifdef read_implementation}

{ TTextNode ----------------------------------------------- }

procedure TTextNode.SetLength(const Value: array of Single);
begin
  FdLength.Send(Value);
end;

procedure TTextNode.SetLength(const Value: TSingleList);
begin
  FdLength.Send(Value);
end;

function TTextNode.GetMaxExtent: Single;
begin
  Result := FdMaxExtent.Value;
end;

procedure TTextNode.SetMaxExtent(const Value: Single);
begin
  FdMaxExtent.Send(Value);
end;

function TTextNode.GetMaxDisplayChars: Integer;
begin
  Result := FdMaxDisplayChars.Value;
end;

procedure TTextNode.SetMaxDisplayChars(const Value: Integer);
begin
  FdMaxDisplayChars.Send(Value);
end;

procedure TTextNode.SetString(const Value: array of string);
begin
  FdString.Send(Value);
end;

procedure TTextNode.SetString(const Value: TCastleStringList);
begin
  FdString.Send(Value);
end;

{$endif read_implementation}
