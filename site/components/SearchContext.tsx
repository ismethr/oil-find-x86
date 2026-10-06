'use client';

import { createContext, useCallback, useContext, useMemo, useRef, type ReactNode } from 'react';

interface SearchActions {
  fill: (query: string) => void;
  register: (fill: (query: string) => void) => () => void;
}
const SearchContext = createContext<SearchActions | null>(null);
export function SearchProvider({ children }: { children: ReactNode }) {
  const action = useRef<((query: string) => void) | null>(null);
  const fill = useCallback((query: string) => action.current?.(query), []);
  const register = useCallback((callback: (query: string) => void) => {
    action.current = callback;
    return () => { if (action.current === callback) action.current = null; };
  }, []);
  const value = useMemo(() => ({ fill, register }), [fill, register]);
  return <SearchContext.Provider value={value}>{children}</SearchContext.Provider>;
}
export function useSearchActions(): SearchActions {
  const value = useContext(SearchContext);
  if (!value) throw new Error('SearchProvider is required');
  return value;
}
