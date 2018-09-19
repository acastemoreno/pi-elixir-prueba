const path = require('path');
module.exports = function(env) {
  const production = process.env.NODE_ENV === 'production';
  return {
    devtool: production ? 'source-maps' : 'eval',
    mode: production ? 'production' : 'development',
    entry: './js/app.js',
    output: {
      path: path.resolve(__dirname, '../priv/static/js'),
      filename: 'app.js',
      publicPath: '/',
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
          },
        },
      ],
    },
    resolve: {
      modules: ['node_modules', path.resolve(__dirname, 'js')],
      extensions: ['.js, .json'],
      alias: {
        phoenix_html: path.resolve(__dirname, '../deps/phoenix_html'),
        phoenix: path.resolve(__dirname, '../deps/phoenix')
      }
    },
  };
};
