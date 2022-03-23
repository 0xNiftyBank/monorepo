const withOptimizedImages = require('next-optimized-images');

module.exports = withOptimizedImages({
  images: {
    loader: 'custom',
    disableStaticImages: true
  },
  swcMinify: true,
});
