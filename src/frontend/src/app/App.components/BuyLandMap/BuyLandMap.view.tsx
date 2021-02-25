import * as PropTypes from "prop-types";
import * as React from "react";

import { BuyLandMapStyled, BuyLandMapTile } from "./BuyLandMap.style";

type BuyLandMapProps = {
  x: number;
  y: number;
  landsOnSale: Array<any>;
  setSelectedTokenCallback?: (tokenId: number) => void;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
  setSelectedTokenPriceCallback?: (price: number) => void;
};

export const BuyLandMap = ({
  x,
  y,
  landsOnSale,
  setSelectedTokenCallback,
  setSelectedTokenPriceCallback,
  setXCoordinatesCallback,
  setYCoordinatesCallback,
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
              if (setXCoordinatesCallback && setYCoordinatesCallback && setSelectedTokenCallback && setSelectedTokenPriceCallback) {
                var tokenIdFromCoordinates = 10 * iy + ix + 1;
                setXCoordinatesCallback(ix);
                setYCoordinatesCallback(iy);
                setSelectedTokenCallback(tokenIdFromCoordinates);
                var selectedLand = landsOnSale.find( land => land.id == tokenIdFromCoordinates)
                if (!!selectedLand) {
                  setSelectedTokenPriceCallback(selectedLand.price)
                } else {
                  setSelectedTokenPriceCallback(0)
                }
               console.log(landsOnSale)
               console.log(tokenIdFromCoordinates)
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