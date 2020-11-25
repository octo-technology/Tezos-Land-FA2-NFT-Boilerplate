import * as React from "react";
import * as PropTypes from "prop-types";
import { LandMapStyled, LandMapTile } from "./LandMap.style";

type LandMapProps = {
  x: number;
  y: number;
};

export const LandMap = ({ x, y }: LandMapProps) => (
  <LandMapStyled>
    {[...Array(10).keys()].map((iy) => {
      return [...Array(10).keys()].map((ix) => {
        return <LandMapTile selected={x === ix && y === iy} />;
      });
    })}
  </LandMapStyled>
);

LandMap.propTypes = {
  x: PropTypes.number,
  y: PropTypes.number,
};

LandMap.defaultProps = {};
