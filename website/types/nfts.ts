export interface ERC721Metadata {
  name: string;
  description?: string;
  attributes?: Array<{ trait_type: 'string'; value: 'string' }>;
  image: string;
}
