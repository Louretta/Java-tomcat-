package com.example.resource;

import com.example.model.Person;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.ArrayList;
import java.util.List;

@Path("/persons")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PersonResource {

    private static List<Person> persons = new ArrayList<>();
    private static Long idCounter = 1L;

    @GET
    public List<Person> getAllPersons() {
        return persons;
    }

    @GET
    @Path("/{id}")
    public Person getPerson(@PathParam("id") Long id) {
        return persons.stream().filter(p -> p.getId().equals(id)).findFirst().orElse(null);
    }

    @POST
    public Response createPerson(Person person) {
        person.setId(idCounter++);
        persons.add(person);
        return Response.status(Response.Status.CREATED).entity(person).build();
    }

    @PUT
    @Path("/{id}")
    public Response updatePerson(@PathParam("id") Long id, Person person) {
        Person existingPerson = getPerson(id);
        if (existingPerson == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        existingPerson.setName(person.getName());
        return Response.ok(existingPerson).build();
    }

    @DELETE
    @Path("/{id}")
    public Response deletePerson(@PathParam("id") Long id) {
        Person person = getPerson(id);
        if (person != null) {
            persons.remove(person);
            return Response.noContent().build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }
}