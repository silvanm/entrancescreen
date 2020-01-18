import azureRequest from './azureRequest';
import config from './config';

export class Person {
  constructor(id, name) {
    this.id = id;
    this.name = name;
  }
}

export class PersonList {
  constructor() {
    this.persons = [];
  }

  async load() {
    let response = await azureRequest(`persongroups/${config.persongroupId}/persons
`, [], {}, 'get');
    //this.messages = response.content;
    //let person = new Person(this.personName, this.personName);
    response.data.forEach((item) => {
      let person = new Person(item.personId, item.name);
      this.persons.push(person);
    });
  }

  async addPerson(person) {
    let response = await azureRequest(`persongroups/${config.persongroupId}/persons
`, [], {
      name: person.name
    }, 'post');
    this.persons.push(person);
    return response.statusText;
  }

  async deletePerson(person) {
    let response = await azureRequest(`persongroups/${config.persongroupId}/persons
/${person.id}`, [], {}, 'delete');
    this.persons.splice(this.persons.indexOf(person), 1);
    return response.statusText;
  }
}
