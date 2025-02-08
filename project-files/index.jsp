<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Person Management</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<div class="container">
    <h1>Person Management</h1>
    <form id="personForm">
        <div class="form-group">
            <label for="name">Name:</label>
            <input type="text" class="form-control" id="name" name="name">
        </div>
        <button type="submit" class="btn btn-primary">Add Person</button>
    </form>
    <br>
    <h2>Person List</h2>
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody id="personList">
        </tbody>
    </table>
</div>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
    $(document).ready(function () {
        fetchPersons();

        $('#personForm').submit(function (event) {
            event.preventDefault();
            const name = $('#name').val();
            $.ajax({
                url: 'api/persons',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({name: name}),
                success: function () {
                    $('#name').val('');
                    fetchPersons();
                }
            });
        });

        function fetchPersons() {
            $.ajax({
                url: 'api/persons',
                method: 'GET',
                success: function (persons) {
                    $('#personList').empty();
                    persons.forEach(function (person) {
                        $('#personList').append(`
                            <tr>
                                <td>${person.id}</td>
                                <td>${person.name}</td>
                                <td>
                                    <button class="btn btn-danger" onclick="deletePerson(${person.id})">Delete</button>
                                </td>
                            </tr>
                        `);
                    });
                }
            });
        }

        window.deletePerson = function (id) {
            $.ajax({
                url: `api/persons/${id}`,
                method: 'DELETE',
                success: function () {
                    fetchPersons();
                }
            });
        };
    });
</script>
</body>
</html>