import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";

import { Token } from "./Map.controller";
// prettier-ignore
import { MapLandBottom, MapLandDescription, MapLandFirstRow, MapLandLocation, MapLandName, MapLandOnSale, MapLandSecondRow, MapLandStyled, MapLandThirdRow, MapStyled } from "./Map.style";

type MapViewProps = {
  existingTokens: Token[];
};

export const MapView = ({ existingTokens }: MapViewProps) => {
  return (
    <MapStyled>
      {existingTokens.map((existingToken) => (
        <MapLand
          key={existingToken.id}
          token={existingToken}
        />
      ))}
    </MapStyled>
  );
};

const MapLand = ({
  token,
}: {
  token: Token;
}) => {
  return (
    <MapLandStyled key={token.id}>
      <LandMap x={token.position.x} y={token.position.y} />

      <MapLandBottom>
        <MapLandFirstRow>
          <MapLandLocation>
            <svg>
              <use xlinkHref="/icons/sprites.svg#location" />
            </svg>
            <div>{`${token.position.x}, ${token.position.y}`}</div>
          </MapLandLocation>
          <MapLandOnSale isOnSale={token.onSale}>
            {token.onSale ? `On sale for ${token.price / 1000000 } ꜩ` : "Not on sale"}
          </MapLandOnSale>
        </MapLandFirstRow>

        <MapLandSecondRow>
          <MapLandName>
            {token.name}
          </MapLandName>

        </MapLandSecondRow>
        <MapLandThirdRow>
        <MapLandDescription>
          {token.description}
          </MapLandDescription>
        </MapLandThirdRow>
      </MapLandBottom>
    </MapLandStyled>
  );
};
