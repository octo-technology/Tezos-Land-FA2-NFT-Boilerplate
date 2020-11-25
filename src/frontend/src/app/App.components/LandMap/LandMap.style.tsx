import styled from "styled-components/macro";

export const LandMapStyled = styled.div`
  height: 230px;
  width: 230px;
  display: grid;
  grid-template-columns: repeat(10, 1fr);
`;

export const LandMapTile = styled.div<{ selected: boolean }>`
  height: 23px;
  width: 23px;
  border: 1px solid #141B43;
  background-color: ${(props) => (props.selected ? "#E50000" : "#202337")};
`;
