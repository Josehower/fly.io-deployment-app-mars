exports.up = async (client) => {
  await client`create table martians (
		id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
		name varchar(40) NOT NULL,
		age integer NOT NULL
	)`;
};

exports.down = async (client) => {
  await client`
    DROP TABLE martians
  `;
};