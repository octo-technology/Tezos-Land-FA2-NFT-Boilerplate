import { DropDown } from "app/App.components/DropDown/DropDown.controller";
import { Input } from "app/App.components/Input/Input.controller";
import {AdminButton, AdminInput} from "./Admin.style";
import {
  HomeButton,
  HomeButtonBorder,
  HomeButtonText,
} from "pages/Home/Home.style";
import * as React from "react";
import { useState } from "react";
type AdminViewProps = {
  mint: ({}: any) => void;
  connectedUser: string;
};

export const AdminView = ({ mint, connectedUser }: AdminViewProps) => {
  const values: ReadonlyArray<string> = [
    "Road",
    "Land",
    "Water",
    "Plaza",
    "District",
  ];
  const [xCoordinate, setXCoordinate] = useState<number>();
  const [yCoordinate, setYCoordinate] = useState<number>();
  const [landName, setLandName] = useState<string>();
  const [landDescription, setLandDescription] = useState<string>();
  const [isOpen, setOpen] = useState(false);
  const [itemSelected, setItemSelected] = useState(values[0]);
  const clickItem = (value: string) => {
    setItemSelected(value);
    setOpen(!isOpen);
  };
  const clickCallback = () => {
    setOpen(!isOpen);
  };
  const test: boolean = true;
  return (
    <>
      <AdminInput
        placeholder="x coordinate"
        onChange={(e) => {
          console.log(e.target.value)
          if(!isNaN(Number(e.target.value))) {
            if(e.target.value){
              setXCoordinate(parseInt(e.target.value))
            } else {
              setXCoordinate(undefined)
            }
            }}

          }
        onBlur={() => {}}
        value={xCoordinate}
      />
      <AdminInput
        placeholder="y coordinate"
        onChange={(e) => {
          console.log(e.target.value)
          if(!isNaN(Number(e.target.value))) {
            if(e.target.value){
              setYCoordinate(parseInt(e.target.value))
            } else {
              setYCoordinate(undefined)
            }
            }}

          }
        onBlur={() => {}}
        value={yCoordinate}
      />
      <AdminInput
        placeholder="name"
        onChange={(e) => setLandName(e.target.value)}
        onBlur={() => {}}
        value={landName}
      />
      <AdminInput
        placeholder="description"
        onChange={(e) => setLandDescription(e.target.value)}
        onBlur={() => {}}
        value={landDescription}
      />
      <AdminButton onClick={() =>
            mint({
              owner: connectedUser,
              landType: itemSelected.toLowerCase(),
              xCoordinates: xCoordinate,
              yCoordinates: yCoordinate,
              landName: landName,
              description: landDescription,
            })
          }>Mint a land</AdminButton>
    </>
  );
};
