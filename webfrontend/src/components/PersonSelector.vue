<template>
    <div :style="{left: x + 'px', top: y + 'px'}">
        <button v-for="person in personlist.persons" v-bind:key="person.id"
                v-on:click="$emit('personSelect', person.id)">{{person.name}}
        </button>
    </div>
</template>

<script>
  import { PersonList } from '../models';

  export default {
    name: 'PersonSelector',
    props: {
      x: Number,
      y: Number
    },
    data() {
      return {
        personlist: []
      };
    },
    mounted() {
      this.personlist = new PersonList();
      this.personlist.load();
    }
  };
</script>

<style scoped>

</style>
