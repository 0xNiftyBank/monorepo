/**
 * Resolves both IPFS and HTTP/HTTPS urls
 */
export const resolveUrl = (url: string): string => {
  const isIpfs = /^ipfs:\/\//.test(url);
  if (isIpfs) {
    const ipfsPath = url.replace('ipfs://', '');
    return `https://ipfs.io/ipfs/${ipfsPath}`;
  }

  return url;
};
