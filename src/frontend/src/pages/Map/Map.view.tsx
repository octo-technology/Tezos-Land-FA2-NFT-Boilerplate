import { AllLandMap } from "app/App.components/AllLandsMap/AllLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { Token } from "./Map.controller";
// prettier-ignore
import { MapLandBottom, MapLandButton, MapLandCoordinateInput, MapLandDescriptionInput, MapLandFirstRow, MapLandLocation, MapLandNameInput, MapLandStyled, MapStyled } from "./Map.style";

type MintProps = {
  owner: string;
  landType: string;
  xCoordinates: number;
  yCoordinates: number;
  landName: string;
  description: string;
};

type MapViewProps = {
  existingTokens: Token[];
};

export const MapView = ({ existingTokens }: MapViewProps) => {
  return (
    <MapStyled>
      <MapLand existingTokens={existingTokens} />
    </MapStyled>
  );
};

const MapLand = ({ existingTokens }: MapViewProps) => {
  const [xCoordinate, setXCoordinate] = useState<number>(0);
  const [yCoordinate, setYCoordinate] = useState<number>(0);
  const [selectedToken, setSelectedToken] = useState<number>(1);
  const alert = useAlert()
  
  return (
    <MapLandStyled>
      <AllLandMap
        x={xCoordinate}
        y={yCoordinate}
        existingTokens={existingTokens}
        setSelectedTokenCallback={setSelectedToken}
        setXCoordinatesCallback={setXCoordinate}
        setYCoordinatesCallback={setYCoordinate}
      />

      <MapLandBottom>
        <MapLandFirstRow>
          <MapLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <MapLandCoordinateInput
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
            ></MapLandCoordinateInput>
            <MapLandCoordinateInput
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
            ></MapLandCoordinateInput>
          </MapLandLocation>
        </MapLandFirstRow>
        <MapLandNameInput
          value={existingTokens.filter( token => token.id == selectedToken ).length == 1 ? existingTokens.filter( token => token.id == selectedToken )[0].name : ""}
          placeholder="Name"
        />
        <MapLandDescriptionInput
          value={existingTokens.filter( token => token.id == selectedToken ).length == 1 ? existingTokens.filter( token => token.id == selectedToken )[0].description  : "" }
          placeholder="Description"
        />
      </MapLandBottom>
    </MapLandStyled>
  );
};
