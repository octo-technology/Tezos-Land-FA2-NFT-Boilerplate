import { AllLandMap } from "app/App.components/AllLandsMap/AllLandMap.view";
import * as React from "react";
import { useState } from "react";
import { useAlert } from 'react-alert'
import { Token } from "./Map.controller";
// prettier-ignore
import { MapLandBottom, MapLandSecondRow , MapLandThirdRow, MapLandOwner, MapLandId, MapLandCoordinateInput, MapLandDescriptionInput, MapLandFirstRow, MapLandLocation, MapLandNameInput, MapLandStyled, MapStyled } from "./Map.style";

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
  const [selectedToken, setSelectedToken] = useState<Token> (existingTokens[0])
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
        <MapLandThirdRow>
        <MapLandId>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${xCoordinate + 1 + 10 * yCoordinate}`}</div>
        </MapLandId>
        </MapLandThirdRow>
      
        <MapLandSecondRow>
        {selectedToken === undefined ? (<>This land does not exist </>) : (<> 
        <MapLandOwner>
        <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${selectedToken.owner}`}</div>
        </MapLandOwner>
        
        </>)
          }
        </MapLandSecondRow>
        <MapLandNameInput
          value={selectedToken === undefined ? "" : selectedToken.name}
          placeholder="Name"
        />
        <MapLandDescriptionInput
          value={selectedToken === undefined ? "" : selectedToken.description }
          placeholder="Description"
        />
      </MapLandBottom>
    </MapLandStyled>
  );
};
