import { LandMap } from "app/App.components/LandMap/LandMap.view";
import * as React from "react";
import { useState } from "react";

import { Token } from "./Map.controller";
// prettier-ignore
import { MapLandBottom, MapLandFirstRow, MapLandLocation, MapLandOnSale, MapLandSecondRow, MapLandThirdRow, MapLandStyled, MapLandDescription, MapLandName} from "./Map.style";

type MapViewProps = {
  existingTokens: Token[];
};

export const MapView = ({ existingTokens }: MapViewProps) => {
  return (
    <>
      {existingTokens.map((existingToken) => (
        <MapLand
          key={existingToken.id}
          token={existingToken}
        />
      ))}
    </>
  );
};

const MapLand = ({
  token,
}: {
  token: Token;
}) => {
  const [price, setPrice] = useState<string>("");

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
          <MapLandOnSale onSale={token.onSale}>
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
