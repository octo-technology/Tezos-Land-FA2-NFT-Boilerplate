import * as PropTypes from "prop-types";
import * as React from "react";

import { BuyLandMapStyled, BuyLandMapTile } from "./BuyLandMap.style";

type BuyLandMapProps = {
  x: number;
  y: number;
  landsOnSale: Array<any>;
  setSelectedTokenCallback?: (token: any) => void;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
};

export const BuyLandMap = ({
  x,
  y,
  landsOnSale,
  setXCoordinatesCallback,
  setYCoordinatesCallback,
  setSelectedTokenCallback
}: BuyLandMapProps) => (
  <BuyLandMapStyled>
    {[...Array(10).keys()].map((iy) => {
      return [...Array(10).keys()].map((ix) => {
        return (
          <BuyLandMapTile
            selected={x === ix && y === iy}
            isOwned={false}
            isOnSale={landsOnSale.filter( land => land.position.x == ix && land.position.y == iy).length > 0}
            key={`${iy}-${ix}`}
            onClick={() => {
              if (setXCoordinatesCallback && setYCoordinatesCallback && setSelectedTokenCallback) {
                var tokenIdFromCoordinates = 10 * iy + ix + 1;
                setXCoordinatesCallback(ix);
                setYCoordinatesCallback(iy);
                var selectedLand = landsOnSale.find( land => land.id == tokenIdFromCoordinates)
                if (!!selectedLand) {
                  setSelectedTokenCallback(selectedLand)
                } else {
                  setSelectedTokenCallback(undefined)
                }
              }
            }}
          />
        );
      });
    })}
  </BuyLandMapStyled>
);

BuyLandMap.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
};

BuyLandMap.defaultProps = {};

// tokensOnSale.map(token => [token.position.x, token.position.y])