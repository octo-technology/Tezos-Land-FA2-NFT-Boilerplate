import styled from "styled-components/macro";

export const LandMapStyled = styled.div<{ isAdmin: boolean }>`
  height: ${(props) => (props.isAdmin ? "500px" : "230px")};
  width: ${(props) => (props.isAdmin ? "500px" : "230px")};
  display: grid;
  grid-template-columns: repeat(10, 1fr);
`;

export const LandMapTile = styled.div<{ selected: boolean; isAdmin: boolean }>`
  height: ${(props) => (props.isAdmin ? "50px" : "23px")};
  width: ${(props) => (props.isAdmin ? "50px" : "23px")};
  border: 1px solid #141b43;
  background-color: ${(props) => (props.selected ? "#E50000" : "#202337")};
`;
