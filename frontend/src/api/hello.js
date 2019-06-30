export default {
  hello(callback) {
    return fetch('http://localhost:3000/', {
      method: 'GET'
    }).then(response => response.json())
  }
}

