import styled from "styled-components/macro";

export const MapStyled = styled.div`
  margin: 30px auto;
  width: 500px;
`;

export const MapLandStyled = styled.div`
  position: relative;
  width: 500px;
`;

export const MapLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const MapLandFirstRow = styled.div`
  position: relative;
  width: 500px;
`;

export const MapLandSecondRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const MapLandThirdRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const MapLandLocation = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr 2fr;
  grid-gap: 1px;
  height: 40px;
  width: 100px;
  line-height: 20px;
  border-radius: 5px;
  background-color: #4c5170;

  > svg {
    display: inline-block;
    width: 24px;
    height: 24px;
    margin: 4px;
    margin-top: 6px;
  }
`;

export const MapLandId = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr;
  grid-gap: 1px;
  height: 25px;
  width: 80px;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  margin-top: 10px;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
  }
`;

export const MapLandOwner = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr;
  grid-gap: 1px;
  height: 25px;
  width: 320px;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  margin-top: 10px;
  padding-right: 2px;
  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
  }
`;


export const MapLandCoordinateInput = styled.input`
  height: 25px;
  text-align: center;
  width: 75%;
  margin-top: 8px;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;

  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const MapLandNameInput = styled.input`
  height: 30px;
  width: 100%;
  margin-top: 5px;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  pointer-events: none;
  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const MapLandDescriptionInput = styled.input`
  height: 60px;
  width: 100%;
  margin-top: 5px;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  text-align: left top;
  pointer-events: none;
  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const MapLandButton = styled.button`
  height: 40px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  margin-top: 5px;
  border-radius: 5px;
  color: #fff;
  cursor: pointer;
`;
