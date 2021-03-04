import * as PropTypes from "prop-types";
import * as React from "react";

import { LandMapStyled, LandMapTile } from "./AdminLandMap.style";

type LandMapProps = {
  x: number;
  y: number;
  isAdmin?: boolean;
  existingTokenIds: Array<number>;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
};

export const LandMap = ({
  x,
  y,
  isAdmin,
  existingTokenIds,
  setXCoordinatesCallback,
  setYCoordinatesCallback,
}: LandMapProps) => (
  <LandMapStyled isAdmin={!!isAdmin}>
    {[...Array(10).keys()].map((iy) => {
      return [...Array(10).keys()].map((ix) => {
        return (
          <LandMapTile
            selected={x === ix && y === iy}
            isAdmin={!!isAdmin}
            exists={existingTokenIds.includes(10 * iy + ix + 1)}
            key={`${iy}-${ix}`}
            onClick={() => {
              if (setXCoordinatesCallback && setYCoordinatesCallback) {
                setXCoordinatesCallback(ix);
                setYCoordinatesCallback(iy);
              }
            }}
          />
        );
      });
    })}
  </LandMapStyled>
);

LandMap.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
};

LandMap.defaultProps = {};
