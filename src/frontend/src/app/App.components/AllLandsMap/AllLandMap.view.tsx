import * as PropTypes from "prop-types";
import * as React from "react";

import { AllLandMapStyled as AllLandMapStyled, AllLandMapTile as AllLandMapTile } from "./AllLandMap.style";

type AllLandMapProps = {
  x: number;
  y: number;
  existingTokens: Array<any>;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
  setSelectedTokenCallback?: (coordinate: number) => void;
};

export const AllLandMap = ({
  x,
  y,
  existingTokens,
  setSelectedTokenCallback,
  setXCoordinatesCallback,
  setYCoordinatesCallback,
}: AllLandMapProps) => (
  <AllLandMapStyled>
    {[...Array(10).keys()].map((iy) => {
      return [...Array(10).keys()].map((ix) => {
        return (
          <AllLandMapTile
            selected={x === ix && y === iy}
            exists={existingTokens.filter( token => token.position.x == ix && token.position.y == iy).length > 0}
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
  </AllLandMapStyled>
);

AllLandMap.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
};

AllLandMap.defaultProps = {};
