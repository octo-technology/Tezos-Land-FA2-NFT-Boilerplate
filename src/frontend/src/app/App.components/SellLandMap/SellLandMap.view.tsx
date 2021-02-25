import * as PropTypes from "prop-types";
import * as React from "react";

import { SellLandMapStyled, SellLandMapTile } from "./SellLandMap.style";

type SellLandMapProps = {
  x: number;
  y: number;
  landsOwned: Array<[any, any]>;
  setSelectedTokenCallback?: (tokenId: number) => void;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
};

export const SellLandMap = ({
  x,
  y,
  landsOwned,
  setSelectedTokenCallback,
  setXCoordinatesCallback,
  setYCoordinatesCallback,
}: SellLandMapProps) => (
  <SellLandMapStyled>
    {[...Array(10).keys()].map((iy) => {
      return [...Array(10).keys()].map((ix) => {
        return (
          <SellLandMapTile
            selected={x === ix && y === iy}
            isOwned={landsOwned.filter( land => land.length > 0 ? land[0] == ix && land[1] == iy : null).length > 0}
            key={`${iy}-${ix}`}
            onClick={() => {
              if (setXCoordinatesCallback && setYCoordinatesCallback && setSelectedTokenCallback) {
                var tokenIdFromCoordinates = 10 * iy + ix + 1;
                setXCoordinatesCallback(ix);
                setYCoordinatesCallback(iy);
                setSelectedTokenCallback(tokenIdFromCoordinates);
              }
            }}
          />
        );
      });
    })}
  </SellLandMapStyled>
);

SellLandMap.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
};

SellLandMap.defaultProps = {};
