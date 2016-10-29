var express = require('express');
var router = express.Router();

/* GET antonyms listing. */
router.get('/', function(req, res, next) {
  res.send(
    JSON.stringify({ phrases: [
      { phrase: '死にたい', anthonym: '生きろ!' }
    ]})
  );
});

module.exports = router;
