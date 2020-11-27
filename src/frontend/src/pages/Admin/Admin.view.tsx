import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useState } from "react";
// prettier-ignore
import { AdminLandBottom, AdminLandButton, AdminLandCoordinateInput, AdminLandDescriptionInput, AdminLandFirstRow, AdminLandLocation, AdminLandNameInput, AdminLandStyled } from "./Admin.style";

type AdminViewProps = {
  mintCallBack: ({}: any) => void;
  connectedUser: string;
};

export const AdminView = ({ mintCallBack, connectedUser }: AdminViewProps) => {
  return (
    <>
      <AdminLand mintCallBack={mintCallBack} connectedUser={connectedUser} />
    </>
  );
};

const AdminLand = ({ mintCallBack, connectedUser }: AdminViewProps) => {
  const [landName, setName] = useState<string>("");
  const [landDescription, setDescription] = useState<string>("");
  const [xCoordinate, setXCoordinate] = useState<number>(0);
  const [yCoordinate, setYCoordinate] = useState<number>(0);

  return (
    <AdminLandStyled>
      <LandMap
        x={xCoordinate}
        y={yCoordinate}
        isAdmin={true}
        setXCoordinatesCallback={setXCoordinate}
        setYCoordinatesCallback={setYCoordinate}
      />

      <AdminLandBottom>
        <AdminLandFirstRow>
          <AdminLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <AdminLandCoordinateInput
              value={xCoordinate}
              onChange={(e) => {
                if (!isNaN(Number(e.target.value))) {
                  if (e.target.value) {
                    setXCoordinate(parseInt(e.target.value));
                  } else {
                    setXCoordinate(0);
                  }
                }
              }}
              placeholder="x"
            ></AdminLandCoordinateInput>
            <AdminLandCoordinateInput
              value={yCoordinate}
              onChange={(e) => {
                if (!isNaN(Number(e.target.value))) {
                  if (e.target.value) {
                    setYCoordinate(parseInt(e.target.value));
                  } else {
                    setYCoordinate(0);
                  }
                }
              }}
              placeholder="y"
            ></AdminLandCoordinateInput>
          </AdminLandLocation>
        </AdminLandFirstRow>
        <AdminLandNameInput
          value={landName}
          onChange={(e) => setName(e.target.value)}
          placeholder="Name"
        />
        <AdminLandDescriptionInput
          value={landDescription}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Description"
        />
        <AdminLandButton
          onClick={() =>
            mintCallBack({
              owner: connectedUser,
              landType: "land",
              xCoordinates: xCoordinate,
              yCoordinates: yCoordinate,
              landName: landName,
              description: landDescription,
            })
          }
        >
          Mint a land
        </AdminLandButton>
      </AdminLandBottom>
    </AdminLandStyled>
  );
};
