import { useEffect, useRef } from 'react';

export const useInterval = (callback: any, delay: number) => {
  const savedCallback = useRef<any>();

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    function tick() {
      if(savedCallback) savedCallback.current();
    }
    let id = setInterval(tick, delay || 1000);
      return () => clearInterval(id);
  }, [delay]);
}