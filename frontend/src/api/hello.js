export default {
  async hello () {
    const response = await fetch('http://localhost:3000/', {
      method: 'GET'
    });
    return await response.json();
  },
  async dbtest () {
    const response = await fetch('http://localhost:3000/dbtest/select', {
      method: 'GET'
    });
    return await response.json();
  }
}
