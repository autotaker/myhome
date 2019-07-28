export default {
  hello () {
    return fetch('http://localhost:3000/', {
      method: 'GET'
    }).then(response => response.json())
  },
  dbtest () {
    return fetch('http://localhost:3000/dbtest/select', {
      method: 'GET'
    }).then(response => response.json())
  }
}
