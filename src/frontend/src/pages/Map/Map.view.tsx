import { AllLandMapTile } from "app/App.components/AllLandsMap/AllLandMap.style";
import { AllLandMap } from "app/App.components/AllLandsMap/AllLandMap.view";
import { useState } from "react";

import { Token } from "./Map.controller";
// prettier-ignore
import { DescriptionTextArea, LegendDiv, LegendRow, MapLandBottom, MapLandCoordinateInput, MapLandFirstRow, MapLandId, MapLandLocation, MapLandOwner, MapLandStyled, MapStyled, NameTextArea } from "./Map.style";

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
  const [selectedToken, setSelectedToken] = useState<Token>(existingTokens[0]);

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
            />
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
            />
          </MapLandLocation>

          <MapLandId>
            <svg>
              <use xlinkHref="/icons/sprites.svg#barcode" />
            </svg>
            <div>{`${xCoordinate + 1 + 10 * yCoordinate}`}</div>
          </MapLandId>

          <div>
            {selectedToken === undefined ? (
              <MapLandOwner>
                <svg>
                  <use xlinkHref="/icons/sprites.svg#unknownOwner" />
                </svg>
                <div>This land does not exist</div>
              </MapLandOwner>
            ) : (
              <>
                <MapLandOwner>
                  <svg>
                    <use xlinkHref="/icons/sprites.svg#owner" />
                  </svg>
                  <div>{`${selectedToken.owner}`}</div>
                </MapLandOwner>
              </>
            )}
          </div>
        </MapLandFirstRow>
        <NameTextArea>
          {selectedToken
            ? selectedToken.name || "This land has no name"
            : "This land has no name"}
        </NameTextArea>
        <DescriptionTextArea>
          {selectedToken
            ? selectedToken.description || "This land has no description"
            : "This land has no description"}
        </DescriptionTextArea>
      </MapLandBottom>

      <LegendRow>
        <AllLandMapTile key={"legende"} exists={true} legend={true} />
        <LegendDiv>Minted token</LegendDiv>
      </LegendRow>
      <LegendRow>
        <AllLandMapTile key={"legende"} exists={false} legend={true} />
        <LegendDiv>Not yet minted token</LegendDiv>
      </LegendRow>
      <LegendRow>
        <AllLandMapTile key={"legende"} exists={true} legend={true}>
          <svg>
            <use xlinkHref="/icons/sprites.svg#onSale" />
          </svg>
        </AllLandMapTile>
        <LegendDiv>Minted token on sale</LegendDiv>
      </LegendRow>
    </MapLandStyled>
  );
};
