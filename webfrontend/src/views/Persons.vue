<template>
    <div>
        <table>
            <tr v-for="person in personList.persons" v-bind:key="person.id">
                <td><small>{{person.id}}</small></td><td>{{person.name}}</td>
                <td>
                    <button v-on:click="deletePerson(person)">Delete</button>
                </td>
            </tr>
        </table>
        <input type="text" v-model="personName">
        <button v-on:click="addPerson">Add person</button>
        <div>
            <button v-on:click="initPersongroup">Init Persongroup</button>
        </div>
        <p>Status: <b>{{messages}}</b></p>
    </div>
</template>

<script>
  import { Person, PersonList } from '../models';

  import azureRequest from '../azureRequest';
  import config from '../config';

  export default {
    name: 'Persons',

    data() {
      return {
        'personName': '',
        'personList': new PersonList(),
        'messages': '',
      };
    },
    methods: {
      async addPerson() {
        let person = new Person(this.personName, this.personName);
        this.personName = '';
        this.messages = await this.personList.addPerson(person);
      },
      async updatePersonList() {
        this.personList.load();
      },
      async deletePerson(person) {
        this.personList.deletePerson(person);
      },
      async initPersongroup() {
        // Call this only once
        let response = await azureRequest(`persongroups/${config.persongroupId}`, [], {
          name: 'Mühlemann',
          recognitionModel: 'recognition_02'
        }, 'put');
        this.messages = response.statusText;
      }
    },
    mounted() {
      this.updatePersonList();
    }
  };
</script>

<style scoped>

</style>
