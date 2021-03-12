import * as PropTypes from "prop-types";

import { AllLandMapStyled, AllLandMapTile } from "./AllLandMap.style";

type AllLandMapProps = {
  x: number;
  y: number;
  existingTokens: Array<any>;
  setXCoordinatesCallback?: (coordinate: number) => void;
  setYCoordinatesCallback?: (coordinate: number) => void;
  setSelectedTokenCallback: (token: any) => void;
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
            exists={existingTokens.filter(token => token.position.x === ix && token.position.y === iy).length > 0}
            key={`${iy}-${ix}`}
            onClick={() => {
              if (setXCoordinatesCallback && setYCoordinatesCallback && setSelectedTokenCallback) {
                var tokenIdFromCoordinates = 10 * iy + ix + 1;
                var selectedLand = existingTokens.find(land => land.id === tokenIdFromCoordinates)
                setXCoordinatesCallback(ix);
                setYCoordinatesCallback(iy);
                if (!!selectedLand) {
                  setSelectedTokenCallback(selectedLand)
                } else {
                  setSelectedTokenCallback(undefined)
                }
              }
            }}
          >
            { existingTokens.filter(land => land.position.x === ix && land.position.y === iy && land.onSale).length > 0 ? (
              <svg>
                <use xlinkHref="/icons/sprites.svg#onSale" />
              </svg>) :
              (<></>)}
          </AllLandMapTile>
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
